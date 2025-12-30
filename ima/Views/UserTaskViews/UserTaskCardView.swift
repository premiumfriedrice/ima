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
    
    // Helper to calculate progress if subtasks exist
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
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // MARK: - Layer 1: The Main Card
            VStack(alignment: .leading, spacing: 10) {
                // Title Row
                HStack(spacing: 12) {
                    // Checkbox Indicator
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(task.isCompleted ? task.priority.color : .gray.opacity(0.5))
                        .contentTransition(.symbolEffect(.replace)) // iOS 17 animation
                    
                    Text(task.title)
                        .font(.system(.title3, design: .rounded)) // Slightly smaller than Habit title
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .strikethrough(task.isCompleted, color: .gray)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                    
                    Spacer()
                }
                
                // Subtitle Row (Due Date or Subtask Count)
                HStack {
                    if let date = task.dueDate {
                        Text(date.formatted(.dateTime.month().day()))
                    } else {
                        Text(task.subtasks.isEmpty ? "No Deadline" : "\(Int(subtaskProgress))/\(Int(totalSubtasks)) Subtasks")
                    }
                }
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .kerning(1.0)
                .opacity(0.5)
                .foregroundStyle(.white)
                
                // Progress Line (Shows simple line if no subtasks, or actual progress if subtasks exist)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        // Indicator
                        Capsule()
                            .fill(task.priority.color)
                            .frame(width: (subtaskProgress / totalSubtasks) * geometry.size.width, height: 4)
                            .shadow(color: task.priority.color.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 4)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: task.isCompleted)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: subtaskProgress)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.4))
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                task.priority.color.opacity(0.6),
                                task.priority.color.opacity(0.1),
                                task.priority.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            // Visual feedback when completed
            .opacity(task.isCompleted ? 0.6 : 1.0)
            .scaleEffect(task.isCompleted ? 0.98 : 1.0)
            .padding(.horizontal, 20)
            
            // MARK: - Interaction (Toggle Complete)
            .onTapGesture {
                toggleTaskCompletion()
            }
            
            // MARK: - Layer 2: Edit Button (Top Right)
            Button(action: { showingEditSheet = true }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(task.priority.color)
                    .padding(12) // Larger touch target
                    .contentShape(Rectangle()) // Ensures padding is clickable
            }
            .padding(.top, 15)
            .padding(.trailing, 35)
        }
        .sheet(isPresented: $showingEditSheet) {
            UserTaskInfoView(userTask: task)
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
    let task = UserTask(title: "Finish Project", priority: .high)
    ZStack {
        Color.black.ignoresSafeArea()
        UserTaskCardView(task: task)
    }
}
