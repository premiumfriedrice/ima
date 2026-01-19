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
    
    // MARK: - State for Collapsible Section
    @State private var showCompleted: Bool = false
    
    // MARK: - Computed Filters
    
    // 1. MUST DO (Daily Habits + High Priority/Due Tasks)
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
    
    // 2. CAN DO (Weekly/Monthly Habits + Low Priority Tasks)
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
    
    // 3. COMPLETED
    private var completedHabits: [Habit] {
        habits.filter { $0.isFullyDone }
    }
    
    private var completedTasks: [UserTask] {
        tasks.filter { $0.isCompleted }
    }
    
    // Helper for the count badge
    private var totalCompletedCount: Int {
        completedHabits.count + completedTasks.count
    }
    
    var body: some View {
        VStack {
            
            Text("What Can I do today?")
                .foregroundStyle(.white)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
                .zIndex(1) // Ensures it sits on top
            
            ZStack(alignment: .bottom) {
                // MARK: - Main Content Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                    
                    // Empty State Check
                    if mustDoHabits.isEmpty && mustDoTasks.isEmpty &&
                        canDoHabits.isEmpty && canDoTasks.isEmpty &&
                        totalCompletedCount == 0 {
                        
                        ContentUnavailableView(
                            "No Active Items",
                            systemImage: "checkmark.circle.badge.questionmark",
                            description: Text("Create a task or habit to get started.")
                        )
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 50)
                        
                    } else {
                        // MARK: - Pinned Sections
                        LazyVStack(spacing: 10) {
                            
                            // Keep spacer for top safe area if needed
                            Color.clear.frame(height: 0)
                            
                            // MARK: - MUST DO SECTION
                            if !mustDoHabits.isEmpty || !mustDoTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Must Do",
                                    icon: "flame.fill",
                                    color: .orange
                                )) {
                                    ForEach(mustDoHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                    ForEach(mustDoTasks) { task in
                                        UserTaskCardView(task: task)
                                    }
                                }
                            }
                            
                            // MARK: - CAN DO SECTION
                            if !canDoHabits.isEmpty || !canDoTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Can Do",
                                    icon: "calendar.badge.clock",
                                    color: .blue
                                )) {
                                    ForEach(canDoHabits) { habit in
                                        HabitCardView(habit: habit)
                                    }
                                    ForEach(canDoTasks) { task in
                                        UserTaskCardView(task: task)
                                    }
                                }
                            }
                            
                            // MARK: - COMPLETED SECTION (Collapsible)
                            if totalCompletedCount > 0 {
                                VStack(alignment: .leading, spacing: 5) {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            showCompleted.toggle()
                                        }
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.headline)
                                                .foregroundStyle(.green)
                                            
                                            Text("COMPLETED")
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            // Count Badge
                                            HStack(spacing: 0) {
                                                Text("\(totalCompletedCount)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.3))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.5))
                                                    .rotationEffect(.degrees(showCompleted ? 90 : 0))
                                            }
                                        }
                                        .font(.system(.caption, design: .rounded))
                                        .textCase(.uppercase)
                                        .kerning(1.0)
                                        .opacity(0.7)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 25)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if showCompleted {
                                        ForEach(completedHabits) { habit in
                                            HabitCardView(habit: habit)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                        }
                                        ForEach(completedTasks) { task in
                                            UserTaskCardView(task: task)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                        }
                                    }
                                }
//                                .padding(.top, 10)
                            }
                            
                            Color.clear
                                .frame(height: 160)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
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
