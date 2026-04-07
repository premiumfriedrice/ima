//
//  HomeView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 1/4/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appBackground) private var appBackground

    @Query(sort: \UserTask.dateCreated, order: .reverse) private var tasks: [UserTask]
    @Query private var habits: [Habit]

    @State private var selectedHabit: Habit?
    @State private var selectedTask: UserTask?
    @State private var readOnlyHabit: Habit?
    @State private var readOnlyTask: UserTask?
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())

    // Collapsible sections (only used on today's page)
    @State private var isMustDoExpanded = true
    @State private var isCanDoExpanded = true

    // MARK: - Week days

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday == 1) ? -6 : -(weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDay)
    }

    // MARK: - Today's active filters

    private var mustDoHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .daily && !$0.isFullyDone }
    }

    private var mustDoTasks: [UserTask] {
        tasks.filter { task in
            guard !task.isCompleted else { return false }
            let isHighPriority = task.priority == .high
            let isDueTodayOrPast = task.dueDate.map {
                Calendar.current.startOfDay(for: $0) <= Calendar.current.startOfDay(for: Date())
            } ?? false
            return isHighPriority || isDueTodayOrPast
        }
    }

    private var canDoHabits: [Habit] {
        habits.filter { $0.frequencyUnit != .daily && !$0.isFullyDone }
    }

    private var canDoTasks: [UserTask] {
        tasks.filter { task in
            guard !task.isCompleted else { return false }
            let isHighPriority = task.priority == .high
            let isDueTodayOrPast = task.dueDate.map {
                Calendar.current.startOfDay(for: $0) <= Calendar.current.startOfDay(for: Date())
            } ?? false
            return !isHighPriority && !isDueTodayOrPast
        }
    }

    // MARK: - Completed for any day

    private func completedHabits(for day: Date) -> [Habit] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let key = formatter.string(from: day)
        return habits.filter { ($0.completionHistory[key] ?? 0) >= $0.frequencyCount }
    }

    private func completedTasks(for day: Date) -> [UserTask] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let completed = task.dateCompleted else { return false }
            return calendar.isDate(completed, inSameDayAs: day)
        }
    }

    // MARK: - Header

    private var headerOverline: String {
        if isToday {
            return selectedDay.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        } else {
            let count = completedHabits(for: selectedDay).count + completedTasks(for: selectedDay).count
            return "\(count) completed"
        }
    }

    private var headerTitle: String {
        if isToday {
            return "What can I do today?"
        } else {
            return selectedDay.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                // Swipeable day pages
                TabView(selection: $selectedDay) {
                    ForEach(weekDays, id: \.self) { day in
                        let dayIsToday = Calendar.current.isDateInToday(day)

                        ScrollView {
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                Color.clear.frame(height: 0)

                                // MARK: - Today: Must Do + Can Do
                                if dayIsToday {
                                    if !mustDoHabits.isEmpty || !mustDoTasks.isEmpty {
                                        Section(header: SectionHeader(
                                            title: "Must Do",
                                            icon: "flame.fill",
                                            color: .orange,
                                            isExpanded: isMustDoExpanded,
                                            coordinateSpace: "homeScroll-\(day)"
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                isMustDoExpanded.toggle()
                                            }
                                        }
                                        ) {
                                            if isMustDoExpanded {
                                                ForEach(mustDoHabits) { habit in
                                                    HabitCardView(habit: habit)
                                                        .onTapGesture { selectedHabit = habit }
                                                        .padding(.bottom, 10)
                                                }
                                                ForEach(mustDoTasks) { task in
                                                    UserTaskCardView(task: task)
                                                        .onTapGesture { selectedTask = task }
                                                        .padding(.bottom, 10)
                                                }
                                            }
                                        }
                                    }

                                    if !canDoHabits.isEmpty || !canDoTasks.isEmpty {
                                        Section(header: SectionHeader(
                                            title: "Can Do",
                                            icon: "calendar.badge.clock",
                                            color: .blue,
                                            isExpanded: isCanDoExpanded,
                                            coordinateSpace: "homeScroll-\(day)"
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                isCanDoExpanded.toggle()
                                            }
                                        }
                                        ) {
                                            if isCanDoExpanded {
                                                ForEach(canDoHabits) { habit in
                                                    HabitCardView(habit: habit)
                                                        .onTapGesture { selectedHabit = habit }
                                                        .padding(.bottom, 10)
                                                }
                                                ForEach(canDoTasks) { task in
                                                    UserTaskCardView(task: task)
                                                        .onTapGesture { selectedTask = task }
                                                        .padding(.bottom, 10)
                                                }
                                            }
                                        }
                                    }
                                }

                                // MARK: - Completed (every day)
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    coordinateSpace: "homeScroll-\(day)"
                                )) {
                                    let dayHabits = completedHabits(for: day)
                                    let dayTasks = completedTasks(for: day)

                                    if dayHabits.isEmpty && dayTasks.isEmpty {
                                        Text(dayIsToday ? "Nothing completed yet" : "Nothing completed")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.3))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 24)
                                    } else {
                                        ForEach(dayHabits) { habit in
                                            HabitCardView(habit: habit, readOnly: true, displayDate: day)
                                                .onTapGesture { readOnlyHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                        ForEach(dayTasks) { task in
                                            UserTaskCardView(task: task, readOnly: true)
                                                .onTapGesture { readOnlyTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }

                                Color.clear.frame(height: 200).accessibilityHidden(true)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .coordinateSpace(name: "homeScroll-\(day)")
                        .tag(day)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // MARK: - STICKY HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(headerTitle)
                            .foregroundStyle(.white)
                            .font(.title)

                        Text(headerOverline)
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
        }
        .sheet(item: $readOnlyHabit) { habit in
            HabitInfoView(habit: habit, readOnly: true)
        }
        .sheet(item: $readOnlyTask) { task in
            UserTaskInfoView(userTask: task, readOnly: true)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserTask.self, Habit.self, configurations: config)

    func seed(_ context: ModelContext) {
        let habit1 = Habit(title: "Leetcode", frequencyCount: 2, frequencyUnit: .daily)
        let habit2 = Habit(title: "Cardio", frequencyCount: 3, frequencyUnit: .weekly)
        let task1 = UserTask(title: "Submit Report", priority: .high)
        let task2 = UserTask(title: "Clean motorcycle chain", priority: .low)
        task2.isCompleted = true
        task2.dateCompleted = Date()

        context.insert(habit1)
        context.insert(habit2)
        context.insert(task1)
        context.insert(task2)
    }

    seed(container.mainContext)

    return ZStack {
        Color.black.ignoresSafeArea()
        HomeView()
            .modelContainer(container)
    }
}
