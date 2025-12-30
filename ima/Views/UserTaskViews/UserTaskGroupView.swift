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
        ZStack(alignment: .bottom) {
            ScrollView {
                if userTasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        VStack {
                            Text("No Tasks Yet")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                            
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
                    LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                        
                        // Spacer for safe area
                        Color.clear.frame(height: 0)
                        
                        // MARK: - High Priority Section
                        if !highPriorityTasks.isEmpty {
                            Section(header: TaskSectionHeader(
                                title: "High Priority",
                                count: highPriorityTasks.count,
                                icon: "exclamationmark.circle.fill",
                                color: .red)) {
                                ForEach(highPriorityTasks) { task in
                                    UserTaskCardView(task: task)
                                        .onTapGesture { selectedTask = task }
                                }
                            }
                        }
                        
                        // MARK: - Medium Priority Section
                        if !mediumPriorityTasks.isEmpty {
                            Section(header: TaskSectionHeader(
                                title: "Medium Priority",
                                count: mediumPriorityTasks.count,
                                icon: "circle.circle.fill",
                                color: .yellow)) {
                                ForEach(mediumPriorityTasks) { task in
                                    UserTaskCardView(task: task)
                                        .onTapGesture { selectedTask = task }
                                }
                            }
                        }
                        
                        // MARK: - Low Priority Section
                        if !lowPriorityTasks.isEmpty {
                            Section(header: TaskSectionHeader(
                                title: "Low Priority",
                                count: lowPriorityTasks.count,
                                icon: "arrow.down.circle.fill",
                                color: .green)) {
                                ForEach(lowPriorityTasks) { task in
                                    UserTaskCardView(task: task)
                                        .onTapGesture { selectedTask = task }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for floating button
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Filtering Logic
    private var highPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .high }
    }
    
    private var mediumPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .medium }
    }
    
    private var lowPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .low }
    }
}

// MARK: - Header Component
// Reused design language from HabitGroupView
struct TaskSectionHeader: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
            
            // Divider Dot
            Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 4, height: 4)
            
            // Count Subtitle
            Text("\(count) Tasks")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Spacer()
        }
        .padding(.vertical, 8)
        // Glassmorphism background for sticky effect
        .background(.ultraThinMaterial.opacity(0.01))
        .font(.system(.caption, design: .rounded))
        .fontWeight(.bold)
        .textCase(.uppercase)
        .kerning(1.0)
        .opacity(0.7) // Increased opacity slightly for readability
        .foregroundStyle(.white)
        .padding(.leading, 16)
    }
}

#Preview {

    let tasks = [UserTask(
        title: "Preview Task",
        details: "Testing the view",
        priority: .high
    )]

    

    ZStack {

        Color(.black).ignoresSafeArea()

        AnimatedRadialBackground()

        UserTaskGroupView(userTasks: tasks)

    }

        

}
