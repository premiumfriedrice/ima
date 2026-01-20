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
    
    // State for the sheet
    @State private var selectedTask: UserTask?
    
    // 1. State variables for collapsing sections
    @State private var isHighPriorityExpanded = true
    @State private var isMediumPriorityExpanded = true
    @State private var isLowPriorityExpanded = true
    @State private var isCompletedExpanded = true // Set to false if you want it closed by default
    
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
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Color.clear.frame(height: 0)
                            
                            // MARK: - High Priority
                            if !highPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "High Priority",
                                    subtitle: "\(highPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red,
                                    isExpanded: isHighPriorityExpanded, // Pass state
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle()) // Makes entire header tappable
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isHighPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    // Wrap content in if-check
                                    if isHighPriorityExpanded {
                                        ForEach(highPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Medium Priority
                            if !mediumPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Medium Priority",
                                    subtitle: "\(mediumPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .yellow,
                                    isExpanded: isMediumPriorityExpanded,
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isMediumPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isMediumPriorityExpanded {
                                        ForEach(mediumPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Low Priority
                            if !lowPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Low Priority",
                                    subtitle: "\(lowPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .gray,
                                    isExpanded: isLowPriorityExpanded,
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isLowPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isLowPriorityExpanded {
                                        ForEach(lowPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Completed
                            if !completedTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Completed",
                                    subtitle: "\(completedTasks.count) DONE",
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    isExpanded: isCompletedExpanded,
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isCompletedExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isCompletedExpanded {
                                        ForEach(completedTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 200)
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
