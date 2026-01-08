//
//  ProgessRingsWithDots.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/7/26.
//

import SwiftUI

struct ProgressRingWithDots<Content: View>: View {
    var habit: Habit
    
    // How much of the container to fill (0.0 to 1.0)
    var fillFactor: CGFloat = 1.0
    
    @ViewBuilder var innerContent: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            // 1. Determine the base size (square)
            let containerSide = min(geo.size.width, geo.size.height)
            let size = containerSide * fillFactor
            
            // 2. Calculate offset to center the ring in the container
            let xOffset = (geo.size.width - size) / 2
            let yOffset = (geo.size.height - size) / 2
            let center = size / 2
            
            // 3. PROPORTIONAL SCALING
            // We use your 55pt frame as the "Base Unit" to maintain exact look
            // Base: Frame 55 | RingRadius 20 | DotRadius 26 | Stroke 3 | DotSize 3.5
            let scale = size / 55.0
            
            let ringRadius = 20.0 * scale
            let dotRadius = 26.0 * scale
            let strokeWidth = 3.0 * scale
            let dotSize = 3.5 * scale
            
            ZStack {
                // A. Continuous Background Track
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: strokeWidth)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
                
                // B. Active Progress Line
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
                
                // C. Incrementation Dots
                let totalSteps = max(habit.frequencyCount, 1)
                
                ForEach(0..<totalSteps, id: \.self) { index in
                    let anglePerStep = 360.0 / Double(totalSteps)
                    let angle = anglePerStep * Double(index + 1) - 90
                    let isCompleted = index < habit.currentCount
                    
                    Circle()
                        .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.2))
                        .frame(width: dotSize, height: dotSize)
                        .position(
                            x: center + (dotRadius * cos(angle.degreesToRadians)),
                            y: center + (dotRadius * sin(angle.degreesToRadians))
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.03), value: habit.currentCount)
                }
                
                // D. Inner Content
                // We restrict the content size to fit inside the ring (approx diameter 36 at scale 1)
                innerContent()
                    .frame(width: (ringRadius * 2) - strokeWidth, height: (ringRadius * 2) - strokeWidth)
            }
            .frame(width: size, height: size)
            .offset(x: xOffset, y: yOffset)
        }
        // Keeps the view square based on the smallest dimension
        .aspectRatio(1, contentMode: .fit)
    }
}
