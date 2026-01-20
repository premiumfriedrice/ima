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
                        // CHANGE 1: Set spacing to 0 to prevent "early" header pushing
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Color.clear.frame(height: 0)
                            
                            // High Priority
                            if !highPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "High Priority",
                                    subtitle: "\(highPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red,
                                    coordinateSpace: "taskScroll"
                                )) {
                                    ForEach(highPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                            .padding(.bottom, 10) // CHANGE 2: Add spacing manually to items
                                    }
                                }
                            }
                            
                            // Medium Priority
                            if !mediumPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Medium Priority",
                                    subtitle: "\(mediumPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .yellow,
                                    coordinateSpace: "taskScroll"
                                )) {
                                    ForEach(mediumPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                            .padding(.bottom, 10) // CHANGE 2
                                    }
                                }
                            }
                            
                            // Low Priority
                            if !lowPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Low Priority",
                                    subtitle: "\(lowPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .gray,
                                    coordinateSpace: "taskScroll"
                                )) {
                                    ForEach(lowPriorityTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                            .padding(.bottom, 10) // CHANGE 2
                                    }
                                }
                            }
                            
                            // Completed
                            if !completedTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    subtitle: "\(completedTasks.count) DONE",
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    coordinateSpace: "taskScroll"
                                )) {
                                    ForEach(completedTasks) { task in
                                        UserTaskCardView(task: task)
                                            .onTapGesture { selectedTask = task }
                                            .padding(.bottom, 10) // CHANGE 2
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "taskScroll")
                
                // MARK: - STICKY HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Tasks")
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
        UserTaskGroupView(userTasks: tasks)
    }
}
