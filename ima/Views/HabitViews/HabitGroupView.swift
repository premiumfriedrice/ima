//
//  HabitGroupView.swift
//  ima/Views/HabitViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import SwiftUI
import SwiftData

struct HabitGroupView: View {
    @Environment(\.modelContext) private var modelContext

    var habits: [Habit]
    
// MARK: - Date Formatters
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d" // e.g., "DEC 28"
        return f
    }()
    
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM" // e.g., "DECEMBER"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Habits")
                .foregroundStyle(.white)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
                .zIndex(1) // Ensures it sits on top
            
            ZStack(alignment: .bottom) {
                // MARK: - Main Content Area
                ScrollView {
                    if habits.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            VStack {
                                Text("No Habits Yet")
                                    .font(.system(.title2, design: .rounded))
                                
                                Text("Tap the + button to create your first habit.")
                                    .font(.system(.body, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 40)
                        .font(.system(.caption, design: .rounded))
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)
                    }
                    else {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            // MARK: - Daily Section
                            if !dailyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Daily",
                                    subtitle: dayFormatter.string(from: Date()),
                                    icon: "sun.max.fill",
                                    color: .orange,
                                )) {
                                    ForEach(dailyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                            
                            // MARK: - Weekly Section
                            if !weeklyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Weekly",
                                    subtitle: currentWeekRange,
                                    icon: "calendar",
                                    color: .blue
                                )) {
                                    ForEach(weeklyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                            
                            // MARK: - Monthly Section
                            if !monthlyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Monthly",
                                    subtitle: monthFormatter.string(from: Date()),
                                    icon: "moon.stars.fill",
                                    color: .purple
                                )) {
                                    ForEach(monthlyHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                }
                            }
                        }
                        Color.clear
                            .frame(height: 160)
                            .accessibilityHidden(true)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    // MARK: - Filtering & Sorting Logic
    // We add .sorted to push completed habits (isFullyDone == true) to the end
    
    private var dailyHabits: [Habit] {
        habits
            .filter { $0.frequencyUnit == .daily }
            .sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
    private var weeklyHabits: [Habit] {
        habits
            .filter { $0.frequencyUnit == .weekly }
            .sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
    private var monthlyHabits: [Habit] {
        habits
            .filter { $0.frequencyUnit == .monthly }
            .sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
// MARK: - Date Range Calculation
    private var currentWeekRange: String {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate start of week (Sunday or Monday based on locale)
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)
        guard let start = weekInterval?.start, let end = weekInterval?.end else { return "" }
        
        // End date is technically start of next week, subtract 1 second to get Saturday/Sunday night
        let actualEnd = end.addingTimeInterval(-1)
        
        let startStr = dayFormatter.string(from: start)
        let endStr = dayFormatter.string(from: actualEnd)
        
        return "\(startStr) - \(endStr)"
    }
}

#Preview {
    let habits = [
        Habit(title: "LeetCode", frequencyCount: 1, frequencyUnit: .daily),
        Habit(title: "Pray", frequencyCount: 3, frequencyUnit: .daily),
        Habit(title: "Ride Motorcycle", frequencyCount: 1, frequencyUnit: .daily),
        Habit(title: "Lift", frequencyCount: 4, frequencyUnit: .weekly),
        Habit(title: "Cardio", frequencyCount: 3, frequencyUnit: .weekly),
        Habit(title: "Read Book", frequencyCount: 2, frequencyUnit: .monthly),
        Habit(title: "Clean Motorcycle Chain", frequencyCount: 2, frequencyUnit: .monthly),
        Habit(title: "Clean Restroom", frequencyCount: 2, frequencyUnit: .monthly),
        ]
    
    ZStack {
        Color(.black).ignoresSafeArea()
        HabitGroupView(habits: habits)
    }
        
}
