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
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                // Title and Icon Row
                HStack {
                    Text(habit.title)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Stats Button with subtle background
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(habit.statusColor)
                            .padding(8)
                            .background(habit.statusColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                
                // Subtitle with tracking
                Text("\(habit.totalCount)/\(habit.frequencyCount) \(habit.frequencyUnit == .daily ? "today" : "this week")")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .kerning(1.0)
                    .opacity(0.5)
                    .foregroundStyle(.white)
                
                // Refined Progress Bar
                SegmentedProgressBar(
                    value: habit.totalCount,
                    total: habit.frequencyCount,
                    color: habit.statusColor
                )
                .frame(height: 8)
                .shadow(color: habit.statusColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
                // FIX: Place the black color inside another shape or use clipShape
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.4))
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            habit.statusColor.opacity(0.6),
                            habit.statusColor.opacity(0.1),
                            habit.statusColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .opacity(isDoneForToday ? 0.4 : 1.0)
        .scaleEffect(isDoneForToday ? 0.98 : 1.0) // Slight "recede" effect when done
        .padding(.horizontal, 20)
        .onTapGesture {
            incrementHabit()
        }
        .sheet(isPresented: $showingEditSheet) {
            HabitInfoView(habit: habit)
        }
    }

    private func incrementHabit() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if habit.countDoneToday < habit.dailyGoal {
                habit.countDoneToday += 1
                habit.totalCount += 1
            } else {
                habit.totalCount -= habit.countDoneToday
                habit.countDoneToday = 0
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

#Preview {
    let habi = Habit(title: "Habi", frequencyCount: 2, frequencyUnit: .daily)
    
    ZStack{
        Color.black.ignoresSafeArea()
        HabitCardView(habit: habi)
    }
}
