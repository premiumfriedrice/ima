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
    
    // 1. Add state for the sheet
    @State private var selectedTask: UserTask?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Sticky Header
            if !userTasks.isEmpty {
                Text("Tasks")
                    .foregroundStyle(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                    .background(Color.black)
                    .zIndex(1)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    if userTasks.isEmpty {
                        // Empty State
                        VStack(spacing: 12) {
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
                        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                            
                            Color.clear.frame(height: 0)
                            
                            // High Priority
                            if !highPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "High Priority",
                                    subtitle: "\(highPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red
                                ).background(Color.black)) {
                                    ForEach(highPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // Medium Priority
                            if !mediumPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Medium Priority",
                                    subtitle: "\(mediumPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .yellow
                                ).background(Color.black)) {
                                    ForEach(mediumPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // Low Priority
                            if !lowPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Low Priority",
                                    subtitle: "\(lowPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .gray
                                ).background(Color.black)) {
                                    ForEach(lowPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                    }
                                }
                            }
                            
                            // Completed
                            if !completedTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    subtitle: "\(completedTasks.count) DONE",
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
                        .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        // 2. Attach Sheet to Parent View
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
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
