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
    var readOnly: Bool = false
    var displayDate: Date? = nil

    private var displayCount: Int {
        guard let date = displayDate else { return habit.currentCount }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let key = formatter.string(from: date)
        return habit.completionHistory[key] ?? 0
    }

    private var displayDone: Bool {
        displayCount >= habit.frequencyCount
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            
            // MARK: - Left Side: Text Info
            VStack(alignment: .leading, spacing: 5) {
                MarqueeText(text: habit.title, font: .body, foregroundStyle: .white)

                HStack {
                    Text("\(displayCount)/\(habit.frequencyCount) \(timePeriodString)")
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // MARK: - Right Side: Button
            ProgressRingWithDots(habit: habit, fillFactor: 1.0, readOnly: readOnly, overrideCount: displayDate != nil ? displayCount : nil) {
                if readOnly {
                    Color.clear.frame(width: 25, height: 25)
                } else {
                    Button(action: { incrementHabit() }) {
                        Color.clear
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 45, height: 45)
            
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    .white.opacity(0.15),
                    lineWidth: 1
                )
            
        }
        .opacity(displayDone ? 0.3 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: displayDone)
        .shadow(
            color: .white.opacity(displayDone ? 0.0 : 0.1),
            radius: displayDone ? 0 : 5,
            x: 0, y: 0
        )
        .padding(.horizontal, 20)
    }
    
    private func incrementHabit() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.increment()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
