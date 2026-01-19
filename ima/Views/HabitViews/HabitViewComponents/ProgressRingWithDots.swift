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
    
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            // 1. Determine size
            let containerSide = min(geo.size.width, geo.size.height)
            let size = containerSide * fillFactor
            
            // 2. SCALING MATH
            let scale = size / 55.0
            let ringRadius = 17.0 * scale
            let dotRadius = 24.0 * scale
            let strokeWidth = 3.0 * scale
            let dotSize = 4 * scale
            
            ZStack {
                // A. Progress Line
                Circle()
                    .trim(from: 0, to: CGFloat(habit.progress))
                    .stroke(
                        habit.statusColor,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.currentCount)
                    .opacity(habit.currentCount > 0 ? 1.0 : 0.0)
            
                // B. Dots
                let totalSteps = max(habit.frequencyCount, 1)
                let center = size / 2 // Local center for dot positioning
                
                ForEach(0..<totalSteps, id: \.self) { index in
                    let anglePerStep = 360.0 / Double(totalSteps)
                    let angle = anglePerStep * Double(index + 1) - 90
                    let isCompleted = index < habit.currentCount
                    
                    Circle()
                        .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.1))
                        .frame(width: dotSize, height: dotSize)
                        .position(
                            x: center + (dotRadius * cos(angle.degreesToRadians)),
                            y: center + (dotRadius * sin(angle.degreesToRadians))
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.03), value: habit.currentCount)
                }
                
                // D. Inner Content (Counter-rotated)
                innerContent()
                    .frame(width: (ringRadius * 2) - strokeWidth, height: (ringRadius * 2) - strokeWidth)
                    .rotationEffect(.degrees(-rotation))
            }
            // 3. LOCK THE FRAME SIZE
            .frame(width: size, height: size)
            
            // 4. APPLY ROTATION (Around its own center)
            .rotationEffect(.degrees(rotation))
            
            // 5. POSITION EXPLICITLY IN CENTER (Replaces offset)
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            
            // 6. ANIMATION TRIGGER
            // MARK: - MOMENTUM & FRICTION ANIMATION
            .onChange(of: habit.isFullyDone) { _, isDone in
                if isDone {
                    // response: 0.55 (A bit slower than 0.4 to give the spin "weight")
                    // damping: 0.6 (Matches your dot's friction/bounce)
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        rotation += 360
                    }
                }
                
                playSpinHaptic()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func playSpinHaptic() {
        // Run in a Task to allow delays without freezing the UI
        Task {
            // 1. The "Push" (Heavy momentum to start the spin)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred(intensity: 1.0)
            
            // 2. The "Ticks" (Simulating the ring spinning past resistance)
            // We space them out to simulate slowing down (friction)
            try? await Task.sleep(for: .seconds(0.1))
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)

            try? await Task.sleep(for: .seconds(0.15))
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.7)
            
            try? await Task.sleep(for: .seconds(0.25))
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.4)

            // 3. The "Lock" (Final heavy thud when it settles)
            try? await Task.sleep(for: .seconds(0.2))
            let lockGenerator = UIImpactFeedbackGenerator(style: .heavy)
            lockGenerator.impactOccurred(intensity: 0.8)
        }
    }
}
