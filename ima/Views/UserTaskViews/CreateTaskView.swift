//
//  CreateTaskView.swift
//  ima/Views/TaskViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Form State
    @State private var title: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var tempSubtasks: [String] = [] // Store strings temporarily
    @State private var newSubtaskInput: String = ""
    
    @FocusState private var isInputFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            Rectangle()
                .fill(.white.opacity(0.05))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    // Cancel Button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Create Button
                    Button {
                        createTask()
                    } label: {
                        HStack(spacing: 6) {
                            Text("CREATE")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(!title.isEmpty ? .black : .white.opacity(0.3))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(!title.isEmpty ? .white : .white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .disabled(title.isEmpty)
                }
                .padding(25)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Hero Title Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NEW TASK")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("Task Title...", text: $title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .tint(.white)
                                .submitLabel(.next)
                                .focused($isTitleFocused)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        
                        // MARK: - Priority Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRIORITY")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(TaskPriority.allCases) { p in
                                    Button {
                                        withAnimation(.snappy) {
                                            priority = p
                                        }
                                    } label: {
                                        HStack {
                                            if priority == p {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                            }
                                            Text(p.title)
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                        }
                                        .foregroundStyle(priority == p ? .black : .white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(
                                            Capsule()
                                                .fill(priority == p ? p.color : .white.opacity(0.1))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(p.color.opacity(0.5), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                        // MARK: - Subtasks Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("SUBTASKS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 12) {
                                // 1. List of Temporary Subtasks
                                ForEach(Array(tempSubtasks.enumerated()), id: \.offset) { index, subtaskTitle in
                                    HStack(spacing: 12) {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.white.opacity(0.3))
                                        
                                        Text(subtaskTitle)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Button {
                                            deleteTempSubtask(at: index)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                                .padding(8)
                                                .background(.white.opacity(0.05))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(16)
                                    .background(.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                                // 2. Add Subtask Input
                                HStack(spacing: 12) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskInput)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white)
                                        .submitLabel(.done)
                                        .focused($isInputFocused)
                                        .onSubmit {
                                            addTempSubtask()
                                        }
                                    
                                    if !newSubtaskInput.isEmpty {
                                        Button {
                                            addTempSubtask()
                                        } label: {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.system(size: 24))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
            .foregroundStyle(.white)
            .overlay {
                // Shiny Border Overlay
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.2), location: 0.0),
                                .init(color: .white.opacity(0.05), location: 0.2),
                                .init(color: .clear, location: 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            isTitleFocused = true
        }
    }
    
    // MARK: - Logic
    
    private var canCreate: Bool {
        !title.isEmpty
    }
    
    private func addTempSubtask() {
        guard !newSubtaskInput.isEmpty else { return }
        withAnimation {
            tempSubtasks.append(newSubtaskInput)
            newSubtaskInput = ""
            isInputFocused = true // Keep focus to add multiple
        }
    }
    
    private func deleteTempSubtask(at index: Int) {
        withAnimation {
            tempSubtasks.remove(at: index)
        }
    }
    
    private func createTask() {
        // 1. Create the Task
        let newTask = UserTask(title: title, priority: priority)
        
        // 2. Convert temp strings to actual Subtask objects
        let subtaskObjects = tempSubtasks.map { Subtask(title: $0) }
        
        // 3. Assign subtasks (SwiftData handles the inverse relationship)
        newTask.subtasks = subtaskObjects
        
        // 4. Save
        modelContext.insert(newTask)
        
        // 5. Close
        dismiss()
    }
}

#Preview {
    CreateTaskView()
        .modelContainer(for: UserTask.self, inMemory: true)
}
