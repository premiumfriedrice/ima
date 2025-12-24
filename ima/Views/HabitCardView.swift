//
//  HabitCardView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit // Use Bindable for SwiftData objects
    
    var isDoneForToday: Bool {
        habit.countDoneToday >= habit.dailyGoal
    }
    
    var statusColor: Color {
        if isDoneForToday {
            return .green
        } else if habit.countDoneToday > 0 || habit.totalCount > 0 {
            return .orange
        } else {
            return .white.opacity(0.3)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.headline)
                
                Text("\(habit.totalCount)/\(habit.frequencyCount) \(habit.frequencyUnit == .daily ? "today" : "this week")")
                    .font(.caption)
                    .opacity(0.7)
                
                SegmentedProgressBar(
                    value: habit.totalCount,
                    total: habit.frequencyCount,
                    color: statusColor
                )
                .frame(height: 6)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if !isDoneForToday {
                        habit.countDoneToday += 1
                        habit.totalCount += 1
                    } else {
                        habit.totalCount -= habit.countDoneToday
                        habit.countDoneToday = 0
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }) {
                Image(systemName: isDoneForToday ? "square.fill" : "square")
                    .font(.system(size: 32))
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(statusColor.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(statusColor, lineWidth: 1))
        .opacity(isDoneForToday ? 0.3 : 1.0)
        .padding(.horizontal)
    }
}
