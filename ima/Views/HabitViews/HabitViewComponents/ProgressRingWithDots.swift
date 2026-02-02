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
    
    var body: some View {
        GeometryReader { geo in
            // 1. Determine size
            let containerSide = min(geo.size.width, geo.size.height)
            let size = containerSide * fillFactor
            
            // 2. SCALING MATH (Base size reduced to 45.0 to make elements feel tighter)
            let scale = size / 45.0
            
            // --- ADJUSTED METRICS ---
            // Ring is smaller (11.5)
            let ringRadius = 11.5 * scale
            // Orbit is pulled in (17.0)
            let dotRadius = 17.0 * scale
            // Dots are larger (5.0)
            let dotSize = 5.0 * scale
            let strokeWidth = 2.5 * scale
            
            ZStack {
                
                // A. Main Circle (Background)
                // Turns green when done, clear when not
                Circle()
                    .fill(habit.isFullyDone ? .green : .clear)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(
                                habit.isFullyDone ? .clear : .white.opacity(0.3),
                                lineWidth: strokeWidth
                            )
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.isFullyDone)
                
                // B. The "Electrons" (Orbiting Dots)
                // Only visible when UNFINISHED. This ensures they stop/disappear when done.
                if !habit.isFullyDone {
                    ZStack {
                        let totalSteps = max(habit.frequencyCount, 1)
                        let center = size / 2
                        
                        ForEach(0..<totalSteps, id: \.self) { index in
                            let anglePerStep = 360.0 / Double(totalSteps)
                            // Start from -90 (top)
                            let angle = anglePerStep * Double(index + 1) - 90
                            let isCompleted = index < habit.currentCount
                            

                            Circle()
                                .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.1))
                                .frame(width: dotSize, height: dotSize)
                                .position(
                                    x: center + (dotRadius * cos(angle.degreesToRadians)),
                                    y: center + (dotRadius * sin(angle.degreesToRadians))
                                )
                                // Individual dot animation for filling up
                                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.03), value: habit.currentCount)
                            
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.1))
                                    .frame(width: dotSize, height: dotSize)
                                    .position(
                                        x: center + (dotRadius * cos(angle.degreesToRadians)),
                                        y: center + (dotRadius * sin(angle.degreesToRadians))
                                    )
                                // Individual dot animation for filling up
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.03), value: habit.currentCount)
                                
//                                Image(systemName: "plus")
//                                    .foregroundColor(.white.opacity(0.5)) // Set the icon color
//                                    .font(.system(size: dotSize - (dotSize / 4)))
//                                    .position(
//                                        x: center + (dotRadius * cos(angle.degreesToRadians)),
//                                        y: center + (dotRadius * sin(angle.degreesToRadians))
//                                    )
                            }
                        }
                    }
                    .frame(width: size, height: size)
                    // Apply the slow continuous orbit
                    .rotationEffect(.degrees(orbitRotation))
                    .onAppear {
                        // 20-second loop = very slow, subtle movement
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            orbitRotation = 360
                        }
                    }
                }
                
                // C. Center Content (Checkmark or Text)
                Group {
                    if habit.isFullyDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13 * scale, weight: .bold))
                            .foregroundStyle(.black)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        innerContent()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                // Counter-rotate the text so it stays upright during the "Success Spin"
                .rotationEffect(.degrees(-successRotation))
            }
            // 3. Frame & Position
            .frame(width: size, height: size)
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            
            // 4. Success Spin Effect
            // Rotates the whole view when done, then stops.
            .rotationEffect(.degrees(successRotation))
            .onChange(of: habit.isFullyDone) { _, isDone in
                if isDone {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        successRotation += 360
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
