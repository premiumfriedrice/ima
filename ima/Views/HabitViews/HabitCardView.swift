//
//  HabitCardView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit
    @State private var showingInfoSheet: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // MARK: - Left Side: Text Info
            VStack(alignment: .leading, spacing: 10) {
                // Title
                Text(habit.title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack {
                    // Subtitle (Count & Frequency)
                    Text("\(habit.currentCount)/\(habit.frequencyCount) \(timePeriodString)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)
                    Image(systemName: "info.circle")
                        .font(.system(size: 10, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .opacity(0.5)
                }
            }
            
            Spacer()
            
            // MARK: - Right Side: Segmented Ring + Button
//            ZStack {
//                // Shared geometry for the segments
//                let ringLineWidth: CGFloat = 3.5
//                let totalSegments = max(habit.frequencyCount, 1)
//                let gap: CGFloat = totalSegments > 1 ? 0.035 : 0.0
//                
//                // 1. Background Track (Gray Segments)
//                ForEach(0..<totalSegments, id: \.self) { index in
//                    let segmentLength = 1.0 / CGFloat(totalSegments)
//                    let start = (CGFloat(index) * segmentLength) + (gap / 2)
//                    let end = (CGFloat(index + 1) * segmentLength) - (gap / 2)
//                    
//                    Circle()
//                        .trim(from: start, to: end)
//                        .stroke(
//                            Color.white.opacity(0.15),
//                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
//                        )
//                        .rotationEffect(.degrees(-90))
//                }
//                
//                // 2. Active Fill (Color Segments with Mask Animation)
//                ZStack {
//                    ForEach(0..<totalSegments, id: \.self) { index in
//                        let segmentLength = 1.0 / CGFloat(totalSegments)
//                        let start = (CGFloat(index) * segmentLength) + (gap / 2)
//                        let end = (CGFloat(index + 1) * segmentLength) - (gap / 2)
//                        
//                        Circle()
//                            .trim(from: start, to: end)
//                            .stroke(
//                                habit.statusColor,
//                                style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
//                            )
//                            .rotationEffect(.degrees(-90))
//                    }
//                }
//                // The Mask: Grows to reveal the segments underneath
//                .mask {
//                    Circle()
//                        .trim(from: 0, to: CGFloat(habit.progress))
//                        .stroke(Color.white, lineWidth: ringLineWidth)
//                        .rotationEffect(.degrees(-90))
//                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.currentCount)
//                }
//                
//                // 3. Button Icon
//                Button(action: { incrementHabit() }) {
//                    Image(systemName: habit.isFullyDone ? "checkmark" : "plus")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(habit.isFullyDone ? .black : .white)
//                        .frame(width: 32, height: 32)
//                        .background(habit.isFullyDone ? habit.statusColor : .clear)
//                        .clipShape(Circle())
//                }
//                .accessibilityIdentifier("IncrementButton")
//            }
//            .frame(width: 44, height: 44)

            // MARK: - Right Side: Continuous Ring + Incrementation Dots
                        ZStack {
                            let ringRadius: CGFloat = 20
                            let dotRadius: CGFloat = 26
                            let dotSize: CGFloat = 3.5
                            let ringLineWidth: CGFloat = 3.0
                            
                            let totalSteps = max(habit.frequencyCount, 1)
                            
                            // 1. Continuous Background Track
                            Circle()
                                .stroke(
                                    Color.white.opacity(0.1),
                                    lineWidth: ringLineWidth
                                )
                                .frame(width: ringRadius * 2, height: ringRadius * 2)
                            
                            // 2. Continuous Active Progress Line
                            Circle()
                                .trim(from: 0, to: CGFloat(habit.progress))
                                .stroke(
                                    habit.statusColor,
                                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: ringRadius * 2, height: ringRadius * 2)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.currentCount)
                            
                            // 3. Incrementation Dots (Hovering Outside)
                            ForEach(0..<totalSteps, id: \.self) { index in
                                // Calculate angle for this dot
                                let anglePerStep = 360.0 / Double(totalSteps)
                                
                                // CHANGE: Use (index + 1) to place dots at the END of the segment
                                let angle = anglePerStep * Double(index + 1) - 90
                                
                                let isCompleted = index < habit.currentCount
                                
                                Circle()
                                    .fill(isCompleted ? habit.statusColor : Color.white.opacity(0.2))
                                    .frame(width: dotSize, height: dotSize)
                                    .offset(x: dotRadius * cos(angle.degreesToRadians),
                                            y: dotRadius * sin(angle.degreesToRadians))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.03), value: habit.currentCount)
                            }

                            // 4. Button Icon
                            Button(action: { incrementHabit() }) {
                                Image(systemName: habit.isFullyDone ? "checkmark" : "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(habit.isFullyDone ? .black : .white)
                                    .frame(width: 28, height: 28)
                                    .background(habit.isFullyDone ? habit.statusColor : .clear)
                                    .clipShape(Circle())
                            }
                            .accessibilityIdentifier("IncrementButton")
                        }
                        .frame(width: 55, height: 55)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    .white.opacity(0.15),
                    lineWidth: 2
                )
        }
        // Visual feedback based on completion state
        .opacity(habit.isFullyDone ? 0.6 : 1.0)
        .scaleEffect(habit.isFullyDone ? 0.98 : 1.0)
        // MARK: New Highlight Effect
        // Add a soft white glow when NOT completed
        .shadow(
            color: .white.opacity(habit.isFullyDone ? 0.0 : 0.15),
            radius: habit.isFullyDone ? 0 : 10,
            x: 0, y: 0
        )
        .padding(.horizontal, 20)
        
        // MARK: - Interaction (Tap Card to Open Info)
        .onTapGesture {
            showingInfoSheet = true
        }
        .sheet(isPresented: $showingInfoSheet) {
            HabitInfoView(habit: habit)
        }
    }
    
    private func incrementHabit() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.increment()
            // Optional: If targeting iOS 17+, prefer .sensoryFeedback modifier on the view instead
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private var timePeriodString: String {
        switch habit.frequencyUnit {
        case .daily: return "TODAY"
        case .weekly: return "THIS WEEK"
        case .monthly: return "THIS MONTH"
        }
    }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
}

#Preview {
    // Example of an incomplete habit (will show highlight)
    let habitIncomplete = Habit(title: "LeetCode", frequencyCount: 3, frequencyUnit: .daily)
    habitIncomplete.currentCount = 1
    
    // Example of a complete habit (no highlight, dimmed)
    let habitComplete = Habit(title: "Drink Water", frequencyCount: 3, frequencyUnit: .daily)
    habitComplete.currentCount = 3

    return ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            HabitCardView(habit: habitIncomplete)
            HabitCardView(habit: habitComplete)
        }
    }
}
