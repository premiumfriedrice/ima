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
    
    private var showCounts: Bool {
        return !task.subtasks.isEmpty && subtaskProgress < totalSubtasks
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            
            // MARK: - Left Side: Text Info
            VStack(alignment: .leading, spacing: 5) {
                // Title
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.white)
                    .strikethrough(task.isCompleted, color: .gray)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
                    .lineLimit(1)
                
                // Subtitle Row: Priority • Due Date
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(task.priority.color)
                    
                    if let date = task.dueDate {
                        Text(date.formatted(.dateTime.month().day()))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .font(.caption2)
                .textCase(.uppercase)
                .kerning(1.0)
            }
            
            Spacer()
            
            // MARK: - Right Side: Interaction Area
            ZStack {
                if showCounts {
                    // CASE A: Subtask Counts
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(Int(subtaskProgress))")
                            .font(.callout)
                            .foregroundStyle(.white)
                        
                        Text("/\(Int(totalSubtasks))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(width: 40, height: 40) // Matches Habit Button
                    
                } else {
                    // CASE B: Checkmark Button
                    Button(action: { toggleTaskCompletion() }) {
                        Image(systemName: task.isCompleted ? "checkmark" : "")
                            .font(.footnote)
                            .foregroundColor(task.isCompleted ? .black : .clear)
                            .frame(width: 28, height: 28) // Icon visual size
                            .background(task.isCompleted ? .green : .clear)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(task.isCompleted ? .clear : .white.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .frame(width: 40, height: 40) // Hit target matches Habit Button
                    .accessibilityIdentifier("CompleteTaskButton")
                }
            }
            .frame(width: 40, height: 40) // Reference container size (Matches HabitCardView)
        }
        .padding(15)
        
        // MARK: - Card Styling
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    .white.opacity(0.15),
                    lineWidth: 1
                )
        }
        .opacity(task.isCompleted ? 0.5 : 1.0)
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .shadow(
            color: .white.opacity(task.isCompleted ? 0.0 : 0.15),
            radius: task.isCompleted ? 0 : 10,
            x: 0, y: 0
        )
        .padding(.horizontal, 20)
        
        // MARK: - Interaction
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
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
