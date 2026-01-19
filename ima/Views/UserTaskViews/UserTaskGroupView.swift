//
//  UserTaskGroupView.swift
//  ima/Views/UserTaskViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct UserTaskGroupView: View {
    @Environment(\.modelContext) private var modelContext
    
    var userTasks: [UserTask]
    
    // State to track which task is being edited
    @State private var selectedTask: UserTask?
    
    var body: some View {
        VStack(spacing: 0) { // 1. Use VStack to stack Header + Content
            
            // MARK: - Sticky Main Header
            // Shown ONLY if there are tasks, sits outside the ScrollView
            if !userTasks.isEmpty {
                Text("Tasks")
                    .foregroundStyle(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                    .zIndex(1)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    if userTasks.isEmpty {
                        // MARK: - Empty State
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            VStack {
                                Text("No Tasks Yet")
                                    .font(.system(.title2, design: .rounded))
                                
                                Text("Tap the + button to create your first task.")
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
                    } else {
                        // 2. Enable Pinned Views for Section Headers
                        LazyVStack(alignment: .leading, spacing: 10) {
                            
                            // Spacer for safe area / header breathing room
                            Color.clear.frame(height: 0)
                            
                            // MARK: - High Priority (Active)
                            if !highPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "High Priority",
                                    subtitle: "\(highPriorityTasks.count) \(highPriorityTasks.count == 1 ? "TASK" : "TASKS")",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red
                                )) { // 3. Add Black Background to header
                                    ForEach(highPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // MARK: - Medium Priority (Active)
                            if !mediumPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Medium Priority",
                                    subtitle: "\(mediumPriorityTasks.count) \(mediumPriorityTasks.count == 1 ? "TASK" : "TASKS")",
                                    icon: "exclamationmark.circle.fill",
                                    color: .yellow
                                )) {
                                    ForEach(mediumPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // MARK: - Low Priority (Active)
                            if !lowPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Low Priority",
                                    subtitle: "\(lowPriorityTasks.count) \(lowPriorityTasks.count == 1 ? "TASK" : "TASKS")",
                                    icon: "exclamationmark.circle.fill",
                                    color: .gray
                                )) {
                                    ForEach(lowPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // MARK: - Completed Section
                            if !completedTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    subtitle: "\(completedTasks.count) \(completedTasks.count == 1 ? "DONE" : "DONE")",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                ).background(Color.black)) {
                                    ForEach(completedTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100) // Space for floating button
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Filtering Logic
    
    private var highPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .high && !$0.isCompleted }
    }
    
    private var mediumPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .medium && !$0.isCompleted }
    }
    
    private var lowPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .low && !$0.isCompleted }
    }
    
    private var completedTasks: [UserTask] {
        userTasks.filter { $0.isCompleted }
    }
}

#Preview {
    let tasks = [
        UserTask(title: "Active Task", details: "Do this", priority: .high),
        UserTask(title: "Done Task", isCompleted: true, details: "Did this", priority: .medium)
    ]
    
    ZStack {
        Color(.black).ignoresSafeArea()
        // AnimatedRadialBackground() // Uncomment if available
        UserTaskGroupView(userTasks: tasks)
    }
}
