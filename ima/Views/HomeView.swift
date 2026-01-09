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
    
    // 1. MUST DO
    // Now excludes completed habits
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
    
    // 2. CAN DO
    // Now excludes completed habits
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
    // Now includes fully done habits
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
        ZStack {
            ScrollView {
                VStack(spacing: 35) {
                    
                    // MARK: - Header
                    HeaderView()
                    
                    // MARK: - MUST DO SECTION
                    if !mustDoHabits.isEmpty || !mustDoTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionLabel(title: "Must Do", icon: "flame.fill", color: .orange)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(mustDoHabits) { habit in
                                    HabitCardView(habit: habit)
                                }
                                ForEach(mustDoTasks) { task in
                                    UserTaskCardView(task: task)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - CAN DO SECTION
                    if !canDoHabits.isEmpty || !canDoTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionLabel(title: "Can Do", icon: "calendar.badge.clock", color: .blue)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(canDoHabits) { habit in
                                    HabitCardView(habit: habit)
                                }
                                ForEach(canDoTasks) { task in
                                    UserTaskCardView(task: task)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - COMPLETED SECTION (Collapsible)
                    if totalCompletedCount > 0 {
                        VStack(alignment: .leading, spacing: 16) {
                            // Collapsible Header Button
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showCompleted.toggle()
                                }
                            }) {
                                HStack {
                                    SectionLabel(title: "Completed", icon: "checkmark.circle.fill", color: .green)
                                    
                                    Spacer()
                                    
                                    // Count Badge
                                    Text("\(totalCompletedCount)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.white.opacity(0.1))
                                        .clipShape(Capsule())
                                    
                                    // Rotating Chevron
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .rotationEffect(.degrees(showCompleted ? 90 : 0))
                                        .padding(.trailing, 25)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            // The List (Only shown if expanded)
                            if showCompleted {
                                LazyVStack(spacing: 12) {
                                    // 1. Completed Habits
                                    ForEach(completedHabits) { habit in
                                        HabitCardView(habit: habit)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    
                                    // 2. Completed Tasks
                                    ForEach(completedTasks) { task in
                                        UserTaskCardView(task: task)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Empty State
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
                    }
                    
                    // Bottom Spacer
                    Color.clear.frame(height: 100)
                }
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)
            
            Color.clear
                .frame(height: 160)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Helper Views
struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(.dateTime.year().month().day()))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

struct SectionLabel: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.leading, 25)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserTask.self, Habit.self, configurations: config)

    // Seed data helper to avoid non-View statements as the last expression
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
        AnimatedRadial(color: .blue.opacity(0.1), startPoint: .topLeading, endPoint: .bottomTrailing)
        HomeView()
            .modelContainer(container)
    }
}
