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
        HStack(alignment: .center, spacing: 15) {
            
            // MARK: - Left Side: Text Info
            VStack(alignment: .leading, spacing: 5) {
                // Title
                Text(habit.title)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack {
                    Text("\(habit.currentCount)/\(habit.frequencyCount) \(timePeriodString)")
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            // MARK: - Right Side: Continuous Ring + Incrementation Dots
            ProgressRingWithDots(habit: habit, fillFactor: 1.0) {
                Button(action: { incrementHabit() }) {
                    Image(systemName: habit.isFullyDone ? "checkmark" : "plus")
                        .font(.caption)
                        .foregroundColor(habit.isFullyDone ? .clear : .white)
                        .frame(width: 28, height: 28) // Fixed button size for small card
                        .background(habit.isFullyDone ? habit.statusColor : .white.opacity(0.1))
                        .clipShape(Circle())
                        .scaleEffect(habit.isFullyDone ? 0.98 : 1.0)
                }
            }
            .frame(width: 45, height: 45) // The reference size
            
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.5))
        }
        .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.2), location: 0.0),  // Exact match to InfoView
                                .init(color: .white.opacity(0.05), location: 0.2),
                                .init(color: .clear, location: 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5 // Thicker line catches more "light"
                    )
            }
        // Visual feedback based on completion state
        .opacity(habit.isFullyDone ? 0.3 : 1.0)
        .scaleEffect(habit.isFullyDone ? 0.98 : 1.0)
        // MARK: New Highlight Effect
        // Add a soft white glow when NOT completed
        .shadow(
            color: .white.opacity(habit.isFullyDone ? 0.0 : 0.1),
            radius: habit.isFullyDone ? 0 : 5,
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
        case .daily: return "Today"
        case .weekly: return "This week"
        case .monthly: return "This month"
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
    let habitComplete = Habit(title: "Drink Water", frequencyCount: 7, frequencyUnit: .daily)
    habitComplete.currentCount = 3

    return ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 10) {
            HabitCardView(habit: habitIncomplete)
            HabitCardView(habit: habitComplete)
        }
    }
}
