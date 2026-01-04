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
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                AnimatedRadial(color: .blue.opacity(0.1), startPoint: .topLeading, endPoint: .bottomTrailing)
                
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
            }
        }
    }
}

// MARK: - Helper Views

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(date: .complete, time: .omitted).uppercased())
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.5))
                .kerning(1)
            
            Text("Good Morning")
                .font(.system(size: 32, weight: .bold, design: .rounded))
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

// MARK: - Habit Row
struct HabitRowView: View {
    let habit: Habit
    @State private var isCompleted = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Check Circle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isCompleted.toggle()
                    if isCompleted {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(isCompleted ? .green : .white.opacity(0.2))
                    .contentTransition(.symbolEffect(.replace))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .strikethrough(isCompleted)
                    .opacity(isCompleted ? 0.5 : 1)
                
                Text("\(habit.frequencyCount) \(habit.frequencyCount == 1 ? "time" : "times") \(habit.frequencyUnit.rawValue)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Streak Flame
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                Text("0")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.orange.opacity(0.8))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.orange.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserTask.self, Habit.self, configurations: config)
    
    // 1. Must Do Items
    let habit1 = Habit(title: "Pray", frequencyCount: 1, frequencyUnit: .daily)
    let habit2 = Habit(title: "LeetCode", frequencyCount: 2, frequencyUnit: .daily)
    let task1 = UserTask(title: "Submit Report", details: "Due by 5pm", dueDate: Date(), priority: .high)
    
    // 2. Can Do Items
    let habit3 = Habit(title: "Go to Gym", frequencyCount: 3, frequencyUnit: .weekly)
    let task2 = UserTask(title: "Buy Groceries", priority: .medium) // No date
    let task3 = UserTask(title: "Plan Vacation", priority: .low)
    
    container.mainContext.insert(habit1)
    container.mainContext.insert(habit2)
    container.mainContext.insert(habit3)
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)
    
    return HomeView()
        .modelContainer(container)
}
