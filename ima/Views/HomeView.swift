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
    
    // Fetch all items (sorted by creation date)
    @Query(sort: \UserTask.dateCreated, order: .reverse) private var tasks: [UserTask]
    @Query private var habits: [Habit]
    
    // MARK: - Computed Filters
    
    // 1. MUST DO: Daily Habits + High Priority Tasks + Tasks Due Today (or overdue)
    private var mustDoHabits: [Habit] {
        habits.filter { $0.frequencyUnit == .daily }
    }
    
    private var mustDoTasks: [UserTask] {
        tasks.filter { task in
            guard !task.isCompleted else { return false }
            
            let isHighPriority = task.priority == .high
            // Check if due date exists and is today or earlier
            let isDueTodayOrPast = task.dueDate.map {
                Calendar.current.startOfDay(for: $0) <= Calendar.current.startOfDay(for: Date())
            } ?? false
            
            return isHighPriority || isDueTodayOrPast
        }
    }
    
    // 2. CAN DO: Weekly/Monthly Habits + Low/Med Tasks with No Due Date (or future dates)
    private var canDoHabits: [Habit] {
        habits.filter { $0.frequencyUnit != .daily }
    }
    
    private var canDoTasks: [UserTask] {
        tasks.filter { task in
            guard !task.isCompleted else { return false }
            
            // Logic: If it's NOT in "Must Do", it belongs here
            let isHighPriority = task.priority == .high
            let isDueTodayOrPast = task.dueDate.map {
                Calendar.current.startOfDay(for: $0) <= Calendar.current.startOfDay(for: Date())
            } ?? false
            
            return !isHighPriority && !isDueTodayOrPast
        }
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
                                // 1. Habits
                                ForEach(mustDoHabits) { habit in
                                    HabitCardView(habit: habit)
                                }
                                
                                // 2. Tasks (Using your existing Card View)
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
                                // 1. Habits
                                ForEach(canDoHabits) { habit in
                                    HabitCardView(habit: habit)
                                }
                                
                                // 2. Tasks
                                ForEach(canDoTasks) { task in
                                    UserTaskCardView(task: task)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Empty State if nothing exists
                    if mustDoHabits.isEmpty && mustDoTasks.isEmpty && canDoHabits.isEmpty && canDoTasks.isEmpty {
                        ContentUnavailableView(
                            "No Active Items",
                            systemImage: "checkmark.circle.badge.questionmark",
                            description: Text("Create a task or habit to get started.")
                        )
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 50)
                    }
                    
                    // Bottom Padding for scroll
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
//            Text(Date().formatted(date: .complete, time: .omitted).uppercased())
            Text(Date().formatted(.dateTime.year().month().day()))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 45)
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
    
    // Add dummy data...
    let habit1 = Habit(title: "Leetcode", frequencyCount: 1, frequencyUnit: .daily)
    let task1 = UserTask(title: "Submit Report", priority: .high)
    container.mainContext.insert(habit1)
    container.mainContext.insert(task1)
    
    return ZStack {
        Color.black.ignoresSafeArea()
        AnimatedRadial(color: .blue.opacity(0.1), startPoint: .topLeading, endPoint: .bottomTrailing)
        HomeView()
            .modelContainer(container)
    }
}
