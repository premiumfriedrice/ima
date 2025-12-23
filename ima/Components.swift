//
//  HabitCardView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import SwiftUI

struct SegmentedProgressBar: View {
    let value: Int
    let total: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(Double(value) / Double(max(total, 1))))
                
                HStack(spacing: 0) {
                    ForEach(1..<total, id: \.self) { _ in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(Capsule())
    }
}

// 1. Updated HabitCardView to accept a Habit object
struct HabitCardView: View {
    @Binding var habit: Habit
    
    var isDoneForToday: Bool {
        habit.countDoneToday >= habit.dailyGoal
    }
    
    var statusColor: Color {
        if isDoneForToday {
            return .green
        } else if habit.countDoneToday > 0 || habit.totalCount > 0 {
            return .orange
        } else {
            return .white.opacity(0.4)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.headline)
                
                // Dynamic Label
                Text("\(habit.totalCount)/\(habit.frequency.count) \(habit.frequency.frequencyUnit == .daily ? "today" : "this week")")
                    .font(.caption)
                    .opacity(0.7)
                
                SegmentedProgressBar(
                    value: habit.totalCount,
                    total: habit.frequency.count,
                    color: statusColor
                )
                .frame(height: 5)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if !isDoneForToday {
                        habit.countDoneToday += 1
                        habit.totalCount += 1
                    } else {
                        // Reset logic: if they tap while green, it resets today's progress
                        habit.totalCount -= habit.countDoneToday
                        habit.countDoneToday = 0
                    }
                    
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    // 2. Trigger the haptic
                    impactMed.impactOccurred()
                }
            }) {
                Image(systemName: isDoneForToday ? "square.fill" : "square")
                    .font(.system(size: 28))
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(statusColor.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(statusColor, lineWidth: 1))
        .opacity(isDoneForToday ? 0.4 : 1.0)
        .padding(.horizontal)
    }
}

#Preview {
    HabitCardView()
}
