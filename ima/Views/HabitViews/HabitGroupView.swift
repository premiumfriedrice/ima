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
    @Environment(\.appBackground) private var appBackground

    var habits: [Habit]
    
    // 1. Add state to track the active habit for the sheet
    @State private var selectedHabit: Habit?
    @State private var showingCreate = false
    
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
        NavigationStack {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    if habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))

                            VStack {
                                Text("No Habits Yet")
                                    .font(.title2)

                                Text("Tap the + button to create your first habit.")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 40)
                        .font(.caption)
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
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isDailyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isDailyExpanded {
                                        ForEach(dailyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedHabit = habit }
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
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isWeeklyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isWeeklyExpanded {
                                        ForEach(weeklyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedHabit = habit }
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
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isMonthlyExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isMonthlyExpanded {
                                        ForEach(monthlyHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }

                            // MARK: - Achieved Card
                            if !achievedChallengeHabits.isEmpty {
                                NavigationLink {
                                    AchievedHabitsView(habits: achievedChallengeHabits)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "trophy.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(.yellow.gradient)

                                        Text("Achieved")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.5))

                                        Spacer()

                                        Text("\(achievedChallengeHabits.count)")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.4))

                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.ultraThinMaterial.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.white.opacity(0.15), lineWidth: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }
                        }
                        .padding(.bottom, 200)
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "habitScroll")
                
                // MARK: - STICKY HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack {
                        Text("Habits")
                            .foregroundStyle(.white)
                            .font(.title)

                        Spacer()

                        Button { showingCreate = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(10)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .background {
                        ZStack {
                            appBackground
                        }
                        .ignoresSafeArea(edges: .top)
                    }
                }
            }
        }
        .sheet(item: $selectedHabit) { habit in
            HabitInfoView(habit: habit)
        }
        .sheet(isPresented: $showingCreate) {
            CreateHabitView()
        }
        .background(appBackground)
        .navigationBarHidden(true)
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

    private var achievedChallengeHabits: [Habit] {
        habits.filter { habit in
            guard habit.isChallengeHabit else { return false }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            let calendar = Calendar.current
            let goal = habit.frequencyCount

            // Build cycle max map
            var cycleMax: [String: Int] = [:]
            for (dateStr, count) in habit.completionHistory {
                if let date = formatter.date(from: dateStr) {
                    let key: String
                    switch habit.frequencyUnit {
                    case .daily:
                        key = formatter.string(from: date)
                    case .weekly:
                        let y = calendar.component(.yearForWeekOfYear, from: date)
                        let w = calendar.component(.weekOfYear, from: date)
                        key = "\(y)-W\(w)"
                    case .monthly:
                        let comps = calendar.dateComponents([.year, .month], from: date)
                        key = "\(comps.year!)-M\(comps.month!)"
                    }
                    cycleMax[key] = max(cycleMax[key] ?? 0, count)
                }
            }
            let perfectCount = cycleMax.values.filter { $0 >= goal }.count
            return perfectCount >= habit.goalTarget
        }
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
