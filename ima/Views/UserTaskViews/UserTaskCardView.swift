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
    // REMOVED: @State private var showingEditSheet
    
    private var subtaskProgress: Double {
        guard !task.subtasks.isEmpty else { return task.isCompleted ? 1.0 : 0.0 }
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
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.white)
                    .strikethrough(task.isCompleted, color: .gray)
                    .opacity(task.isCompleted ? 0.4 : 1.0)
                    .lineLimit(1)
                
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
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(Int(subtaskProgress))")
                            .font(.callout)
                            .foregroundStyle(.white)
                        
                        Text("/\(Int(totalSubtasks))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(width: 45, height: 45)
                    
                } else {
                    Button(action: { toggleTaskCompletion() }) {
                        Image(systemName: task.isCompleted ? "checkmark" : "")
                            .font(.footnote)
                            .foregroundColor(task.isCompleted ? .black : .clear)
                            .frame(width: 25, height: 25)
                            .background(task.isCompleted ? .green : .clear)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(task.isCompleted ? .clear : .white.opacity(0.3), lineWidth: 2.5)
                            )
                    }
                    .frame(width: 45, height: 45)
                    .accessibilityIdentifier("CompleteTaskButton")
                }
            }
            .frame(width: 40, height: 40)
        }
        .padding(15)
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
        .opacity(task.isCompleted ? 0.3 : 1.0)
        .shadow(
            color: .white.opacity(task.isCompleted ? 0.0 : 0.1),
            radius: task.isCompleted ? 0 : 5,
            x: 0, y: 0
        )
        .padding(.horizontal, 20)
        .contentShape(Rectangle()) // Ensures entire card is tappable
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
