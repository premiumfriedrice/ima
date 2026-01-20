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
    
    // 1. Add state to track the active habit for the sheet
    @State private var selectedHabit: Habit?
    
    // 2. State variables for collapsing sections
    @State private var isDailyExpanded = true
    @State private var isWeeklyExpanded = true
    @State private var isMonthlyExpanded = true
    
    // MARK: - Date Formatters
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()
    
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
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
                        .padding(.top, 100)
                        .font(.system(.caption, design: .rounded))
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)
                    }
                    else {
                        // Set spacing to 0 to prevent "early" header pushing & Pin Headers
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Color.clear.frame(height: 0)
                            
                            // MARK: - Daily Section
                            if !dailyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Daily",
                                    subtitle: dayFormatter.string(from: Date()),
                                    icon: "sun.max.fill",
                                    color: .orange,
                                    isExpanded: isDailyExpanded, // Pass state
                                    coordinateSpace: "habitScroll"
                                )
                                .contentShape(Rectangle()) // Make header tappable
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isDailyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isDailyExpanded {
                                        ForEach(dailyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { selectedHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Weekly Section
                            if !weeklyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Weekly",
                                    subtitle: currentWeekRange,
                                    icon: "calendar",
                                    color: .blue,
                                    isExpanded: isWeeklyExpanded,
                                    coordinateSpace: "habitScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isWeeklyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isWeeklyExpanded {
                                        ForEach(weeklyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { selectedHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Monthly Section
                            if !monthlyHabits.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Monthly",
                                    subtitle: monthFormatter.string(from: Date()),
                                    icon: "moon.stars.fill",
                                    color: .purple,
                                    isExpanded: isMonthlyExpanded,
                                    coordinateSpace: "habitScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isMonthlyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isMonthlyExpanded {
                                        ForEach(monthlyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { selectedHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 200)
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "habitScroll")
                
                // MARK: - STICKY HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Habits")
                            .foregroundStyle(.white)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .zIndex(1)
                    }
                    .background {
                        ZStack {
                            Color.black
                        }
                        .ignoresSafeArea(edges: .top)
                    }
                }
            }
        }
        .sheet(item: $selectedHabit) { habit in
            HabitInfoView(habit: habit)
        }
    }
    
    // MARK: - Filtering & Sorting Logic
    
    private var dailyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .daily }.sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
    private var weeklyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .weekly }.sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
    private var monthlyHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .monthly }.sorted { !$0.isFullyDone && $1.isFullyDone }
    }
    
    private var currentWeekRange: String {
        let calendar = Calendar.current
        let today = Date()
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)
        guard let start = weekInterval?.start, let end = weekInterval?.end else { return "" }
        let actualEnd = end.addingTimeInterval(-1)
        return "\(dayFormatter.string(from: start)) - \(dayFormatter.string(from: actualEnd))"
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
