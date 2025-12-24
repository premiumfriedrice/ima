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
    @State private var showingEditSheet: Bool = false // Renamed for clarity
    
    var isDoneForToday: Bool {
        habit.countDoneToday >= habit.dailyGoal
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.title)
                    .font(.headline)
                
                Text("\(habit.totalCount)/\(habit.frequencyCount) \(habit.frequencyUnit == .daily ? "today" : "this week")")
                    .font(.caption)
                    .opacity(0.7)
                
                SegmentedProgressBar(
                    value: habit.totalCount,
                    total: habit.frequencyCount,
                    color: habit.statusColor
                )
                .frame(height: 6)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: { showingEditSheet = true }) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 16))
                    .foregroundColor(habit.statusColor)
                        }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(habit.statusColor.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(habit.statusColor, lineWidth: 1))
        .opacity(isDoneForToday ? 0.3 : 1.0)
        .padding(.horizontal)
        .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        // We use the logic directly here
                        if habit.countDoneToday < habit.dailyGoal {
                            habit.countDoneToday += 1
                            habit.totalCount += 1
                        } else {
                            // Reset today's progress if already done
                            habit.totalCount -= habit.countDoneToday
                            habit.countDoneToday = 0
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
        }
        .onLongPressGesture {
            
        }
        .sheet(isPresented: $showingEditSheet) {
            HabitInfoView(habit: habit)
        }

    }
}
