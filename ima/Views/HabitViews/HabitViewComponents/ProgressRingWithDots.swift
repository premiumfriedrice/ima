//
//  ProgessRingsWithDots.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/7/26.
//

import SwiftUI

struct ProgressRingWithDots<Content: View>: View {
    var habit: Habit
    var fillFactor: CGFloat = 1.0

    @ViewBuilder var innerContent: () -> Content

    // Tracks the slow, continuous "electron" orbit (Unfinished state)
    @State private var orbitRotation: Double = 0

    // Tracks the fast "success" spin (Transition to Finished state)
    @State private var successRotation: Double = 0

    // Controls animated electron collapse/expand
    @State private var electronsVisible: Bool = true

    var body: some View {
        GeometryReader { geo in
            // 1. Determine size
            let containerSide = min(geo.size.width, geo.size.height)
            let size = containerSide * fillFactor

            // 2. Scaling math (base 45.0)
            let scale = size / 45.0

            // Refined metrics — more breathing room, thinner strokes
            let ringRadius  = 10.0 * scale
            let dotOrbit    = 18.5 * scale
            let dotSize     = 3.5 * scale
            let strokeWidth = 1.5 * scale

            ZStack {
                // Ambient glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                habit.statusColor.opacity(habit.isFullyDone ? 0.25 : Double(habit.currentCount) / Double(max(habit.frequencyCount, 1)) * 0.15),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.45
                        )
                    )
                    .frame(width: size, height: size)
                    .blur(radius: 8 * scale)
                    .animation(.easeInOut(duration: 0.5), value: habit.currentCount)

                // A. Nucleus
                Circle()
                    .fill(habit.isFullyDone ? habit.statusColor : .clear)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(
                                habit.isFullyDone ? .clear : .white.opacity(0.2),
                                lineWidth: strokeWidth
                            )
                    )
                    .shadow(
                        color: habit.isFullyDone ? habit.statusColor.opacity(0.4) : .clear,
                        radius: 8 * scale
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.isFullyDone)

                // B. Electrons (always present, animated visibility)
                ZStack {
                    let totalSteps = max(habit.frequencyCount, 1)
                    let center = size / 2

                    ForEach(0..<totalSteps, id: \.self) { index in
                        let anglePerStep = 360.0 / Double(totalSteps)
                        let angle = anglePerStep * Double(index + 1) - 90
                        let isCompleted = index < habit.currentCount

                        Circle()
                            .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.25))
                            .frame(width: dotSize, height: dotSize)
                            .shadow(
                                color: isCompleted ? habit.statusColor.opacity(0.6) : .clear,
                                radius: 4 * scale
                            )
                            .position(
                                x: center + (dotOrbit * cos(angle.degreesToRadians)),
                                y: center + (dotOrbit * sin(angle.degreesToRadians))
                            )
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.03),
                                value: habit.currentCount
                            )
                    }
                }
                .frame(width: size, height: size)
                .rotationEffect(.degrees(orbitRotation))
                .scaleEffect(electronsVisible ? 1.0 : 0.3)
                .opacity(electronsVisible ? 1.0 : 0.0)
                .onAppear {
                    // Start the slow continuous orbit
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        orbitRotation = 360
                    }
                }

                // C. Center Content (Checkmark or Custom)
                Group {
                    if habit.isFullyDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12 * scale, weight: .bold))
                            .foregroundStyle(.black)
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    } else {
                        innerContent()
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: habit.isFullyDone)
                // Counter-rotate so text stays upright during success spin
                .rotationEffect(.degrees(-successRotation))
            }
            // 3. Frame & Position
            .frame(width: size, height: size)
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)

            // 4. Success Spin
            .rotationEffect(.degrees(successRotation))
            .onAppear {
                electronsVisible = !habit.isFullyDone
            }
            .onChange(of: habit.isFullyDone) { _, isDone in
                if isDone {
                    // Electrons collapse inward
                    withAnimation(.easeIn(duration: 0.4)) {
                        electronsVisible = false
                    }
                    // Success spin starts slightly after collapse begins
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) {
                        successRotation += 360
                    }
                } else {
                    // Electrons expand back outward (decrement case)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        electronsVisible = true
                    }
                }
                playSpinHaptic()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func playSpinHaptic() {
        Task {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred(intensity: 1.0)

            try? await Task.sleep(for: .seconds(0.15))
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)

            try? await Task.sleep(for: .seconds(0.15))
            let lock = UIImpactFeedbackGenerator(style: .heavy)
            lock.impactOccurred(intensity: 0.8)
        }
    }
}
