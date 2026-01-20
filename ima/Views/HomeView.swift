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
    
    // Fetch all items
    @Query(sort: \UserTask.dateCreated, order: .reverse) private var tasks: [UserTask]
    @Query private var habits: [Habit]
    
    // MARK: - State for Sheets
    // Lifted State: Track selection here so sheets survive list re-ordering
    @State private var selectedHabit: Habit?
    @State private var selectedTask: UserTask?
    
    // MARK: - State for Collapsible Sections
    @State private var isMustDoExpanded = true
    @State private var isCanDoExpanded = true
    @State private var isCompletedExpanded = false // Default to collapsed for Completed
    
    // MARK: - Computed Filters
    
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
    
    private var completedHabits: [Habit] {
        habits.filter { $0.isFullyDone }
    }
    
    private var completedTasks: [UserTask] {
        tasks.filter { $0.isCompleted }
    }
    
    private var totalCompletedCount: Int {
        completedHabits.count + completedTasks.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    if mustDoHabits.isEmpty && mustDoTasks.isEmpty &&
                        canDoHabits.isEmpty && canDoTasks.isEmpty &&
                        totalCompletedCount == 0 {
                        
                        ContentUnavailableView(
                            "No Active Items",
                            systemImage: "checkmark.circle.badge.questionmark",
                            description: Text("Create a task or habit to get started.")
                        )
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 100)
                        
                    } else {
                        // Spacing 0 and Pinned Headers
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Color.clear.frame(height: 0)
                            
                            // MARK: - MUST DO SECTION
                            if !mustDoHabits.isEmpty || !mustDoTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Must Do",
                                    icon: "flame.fill",
                                    color: .orange,
                                    isExpanded: isMustDoExpanded,
                                    coordinateSpace: "homeScroll"
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
                            
                            // MARK: - CAN DO SECTION
                            if !canDoHabits.isEmpty || !canDoTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Can Do",
                                    icon: "calendar.badge.clock",
                                    color: .blue,
                                    isExpanded: isCanDoExpanded,
                                    coordinateSpace: "homeScroll"
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
                            
                            // MARK: - COMPLETED SECTION
                            if totalCompletedCount > 0 {
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    subtitle: "\(totalCompletedCount) DONE",
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    isExpanded: isCompletedExpanded,
                                    coordinateSpace: "homeScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isCompletedExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isCompletedExpanded {
                                        ForEach(completedHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                                .onTapGesture { selectedHabit = habit }
                                                .padding(.bottom, 10)
                                        }
                                        ForEach(completedTasks) { task in
                                            UserTaskCardView(task: task)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                                .onTapGesture { selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            Color.clear.frame(height: 200).accessibilityHidden(true)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "homeScroll")
                
                // MARK: - STICKY MAIN HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        Text("What can I do today?")
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
        // Attach Sheets to HomeView (Stable Parent)
        .sheet(item: $selectedHabit) { habit in
            HabitInfoView(habit: habit)
        }
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserTask.self, Habit.self, configurations: config)

    // Seed data helper
    func seed(_ context: ModelContext) {
        let habit1 = Habit(title: "Leetcode", frequencyCount: 2, frequencyUnit: .daily)
        let habit2 = Habit(title: "Cardio", frequencyCount: 3, frequencyUnit: .weekly)
        let task1 = UserTask(title: "Submit Report", priority: .high)
        let task2 = UserTask(title: "Clean motorcycle chain", priority: .low)
        
        // Mark one as done for the completed section
        task2.isCompleted = true
        
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
