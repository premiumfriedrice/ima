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
    var readOnly: Bool = false
    var disableToggle: Bool = false
    
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
                MarqueeText(
                    text: task.title,
                    font: .body,
                    foregroundStyle: task.isCompleted ? .white.opacity(0.4) : .white
                )
                
                if task.isCompleted, let completed = task.dateCompleted {
                    Text("Completed " + completed.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .textCase(.uppercase)
                        .kerning(1.0)
                        .foregroundStyle(.white.opacity(0.5))
                } else {
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
                    
                } else if !readOnly {
                    Button(action: { if !disableToggle { toggleTaskCompletion() } }) {
                        ZStack {
                            Circle()
                                .fill(
                                    task.isCompleted
                                        ? AnyShapeStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Color.clear)
                                )
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            task.isCompleted ? .clear : .white.opacity(0.2),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(
                                    color: task.isCompleted ? .green.opacity(0.4) : .clear,
                                    radius: 8
                                )

                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                            }
                        }
                        .frame(width: 25, height: 25)
                        .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: 45, height: 45)
                    .accessibilityIdentifier("CompleteTaskButton")
                }
            }
            .frame(width: 45, height: 45)
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
            task.dateCompleted = task.isCompleted ? Date() : nil
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
