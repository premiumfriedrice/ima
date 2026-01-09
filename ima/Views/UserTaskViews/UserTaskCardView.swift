//
//  UserTaskCardView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct UserTaskCardView: View {
    @Bindable var task: UserTask
    @State private var showingEditSheet: Bool = false
    
    // MARK: - Computed Properties
    
    private var subtaskProgress: Double {
        guard !task.subtasks.isEmpty else {
            return task.isCompleted ? 1.0 : 0.0
        }
        let completed = task.subtasks.filter { $0.isCompleted }.count
        return Double(completed)
    }
    
    private var totalSubtasks: Double {
        return task.subtasks.isEmpty ? 1.0 : Double(task.subtasks.count)
    }
    
    // Logic: Show counts only if subtasks exist AND are not yet fully complete
    private var showCounts: Bool {
        return !task.subtasks.isEmpty && subtaskProgress < totalSubtasks
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // MARK: - Left Side: Text Info
            VStack(alignment: .leading, spacing: 10) {
                // Title
                Text(task.title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .strikethrough(task.isCompleted, color: .gray)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
                    .lineLimit(1)
                
                // Subtitle Row: Priority • Due Date
                HStack(spacing: 6) {
                    // 1. Priority (Colored)
                    Text(task.priority.title)
                        .foregroundStyle(task.priority.color)
                    
                    // 2. Divider & Date (if exists)
                    if let date = task.dueDate {
                        // Divider Dot
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                        
                        // Date
                        Text(date.formatted(.dateTime.month().day()))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    // 3. Info Icon (if details exist)
                    if !task.details.isEmpty {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.leading, 4)
                    }
                }
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .kerning(1.0)
            }
            
            Spacer()
            
            // MARK: - Right Side: Interaction Area
            ZStack {
                if showCounts {
                    // CASE A: HAS INCOMPLETE SUBTASKS -> Show Numbers Only
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(Int(subtaskProgress))")
                            .font(.system(size: 16, weight: .black, design: .rounded)) // Larger number
                            .foregroundStyle(.white)
                        
                        Text("/\(Int(totalSubtasks))")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(width: 44, height: 44) // Matches button touch area size
                    
                } else {
                    // CASE B: ALL SUBTASKS DONE (or none existed) -> Show Toggle Button
                    Button(action: { toggleTaskCompletion() }) {
                        Image(systemName: task.isCompleted ? "checkmark" : "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(task.isCompleted ? .black : .clear)
                            .frame(width: 28, height: 28)
                            .background(task.isCompleted ? task.priority.color : .clear)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(task.isCompleted ? Color.clear : task.priority.color.opacity(0.5), lineWidth: 2)
                            )
                    }
                    .frame(width: 44, height: 44) // Hit target size
                    .accessibilityIdentifier("CompleteTaskButton")
                }
            }
            .frame(width: 55, height: 55) // Reference container size
        }
        .padding(20)
        
        // MARK: - Card Styling
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    .white.opacity(0.15),
                    lineWidth: 2
                )
        }
        // Visual feedback based on completion state
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        // Glow Effect when active
        .shadow(
            color: .white.opacity(task.isCompleted ? 0.0 : 0.15),
            radius: task.isCompleted ? 0 : 10,
            x: 0, y: 0
        )
        .padding(.horizontal, 20)
        
        // MARK: - Interaction (Open Edit Sheet)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            validateTaskState()
        }) {
            UserTaskInfoView(userTask: task)
        }
    }
    
    // MARK: - Logic Helpers
    
    private func validateTaskState() {
        let hasIncompleteSubtasks = task.subtasks.contains { !$0.isCompleted }
        
        // If the task IS marked complete, but we found an unchecked subtask...
        if task.isCompleted && hasIncompleteSubtasks {
            withAnimation {
                task.isCompleted = false
            }
        }
    }
    
    private func toggleTaskCompletion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            task.isCompleted.toggle()
            if task.isCompleted {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

#Preview {
    let subtasks = [Subtask(title: "Part A", isCompleted: true), Subtask(title: "Part B", isCompleted: false)]
    let taskWithSub = UserTask(title: "Complex Project", priority: .high, subtasks: subtasks)
    
    let subtasksDone = [Subtask(title: "Part A", isCompleted: true), Subtask(title: "Part B", isCompleted: true)]
    let taskReadyToFinish = UserTask(title: "Ready to Finish", priority: .medium, subtasks: subtasksDone)
    
    let simpleTask = UserTask(title: "Buy Milk", priority: .low)
    
    return ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            UserTaskCardView(task: taskWithSub)
            UserTaskCardView(task: taskReadyToFinish)
            UserTaskCardView(task: simpleTask)
        }
    }
}
