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
            
            // MARK: - Right Side: Continuous Ring + Incrementation Dots
            ProgressRingWithDots(habit: habit, fillFactor: 1.0) {
                Button(action: { incrementHabit() }) {
                    Image(systemName: habit.isFullyDone ? "checkmark" : "plus")
                        .font(.system(size: 14, weight: .bold)) // Fixed font size for small card
                        .foregroundColor(habit.isFullyDone ? .black : .white)
                        .frame(width: 28, height: 28) // Fixed button size for small card
                        .background(habit.isFullyDone ? habit.statusColor : .clear)
                        .clipShape(Circle())
                }
            }
            .frame(width: 55, height: 55) // The reference size
            
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
