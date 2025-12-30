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
    
    // Date Logic
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    
    @State private var tempSubtasks: [String] = []
    @State private var newSubtaskInput: String = ""
    @State private var newDetailsInput: String = ""
    
    @FocusState private var isInputFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button { createTask() } label: {
                        HStack(spacing: 6) {
                            Text("CREATE")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(canCreate ? .black : .white.opacity(0.3))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(canCreate ? .white : .white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .disabled(!canCreate)
                }
                .padding(25)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Title Input
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

                        // MARK: - Sentence Row (Priority & Due Date)
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // Row 1: Priority + Text + (Optional "No Date" button)
                            HStack(spacing: 0) {
                                // 1. Scroll Picker (Styled as Pill)
                                Picker("Priority", selection: $priority) {
                                    ForEach(TaskPriority.allCases) { p in
                                        Text("\(p.title)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .tag(p)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 96, height: 84) // Keep this tall for scrolling touch area
                                .compositingGroup()
                                .overlay {
                                    // The "Window" Border
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [priority.color],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                        .frame(width: 78, height: 34) // <--- THIS forces the border to only frame the center item
                                        .allowsHitTesting(false) // Allows touches to pass through to the picker
                                }
                                
                                // 2. Connecting text
                                Text("priority due")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.leading, 12)
                                
                                // 3. "No Date" Button
                                if !hasDueDate {
                                    Button {
                                        withAnimation {
                                            hasDueDate = true
                                            dueDate = Date()
                                        }
                                    } label: {
                                        Text("no date")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.5))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                            .background(.white.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding(.leading, 12)
                                }
                            }
                            
                            // Row 2: Date Picker
                            if hasDueDate {
                                HStack(spacing: 8) {
                                    DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                    
                                    Button {
                                        withAnimation { hasDueDate = false }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                .padding(.top, 0)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                        // MARK: - Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DETAILS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("Add notes, context, or descriptions...", text: $newDetailsInput, axis: .vertical)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(16)
                                .background(.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .lineLimit(3...6)
                        }
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
                                ForEach(Array(tempSubtasks.enumerated()), id: \.offset) { index, subtaskTitle in
                                    HStack(spacing: 12) {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.white.opacity(0.3))
                                        
                                        Text(subtaskTitle)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Button { deleteTempSubtask(at: index) } label: {
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
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskInput)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white)
                                        .submitLabel(.done)
                                        .focused($isInputFocused)
                                        .onSubmit { addTempSubtask() }
                                    
                                    if !newSubtaskInput.isEmpty {
                                        Button { addTempSubtask() } label: {
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
                    .padding(.bottom, 50)
                }
            }
            .foregroundStyle(.white)
            .overlay {
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
            isInputFocused = true
        }
    }
    
    private func deleteTempSubtask(at index: Int) {
        withAnimation {
            tempSubtasks.remove(at: index)
        }
    }
    
    private func createTask() {
        let newTask = UserTask(
            title: title,
            details: newDetailsInput,
            // Only set dueDate if the toggle was ON
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )
        
        let subtaskObjects = tempSubtasks.map { Subtask(title: $0) }
        newTask.subtasks = subtaskObjects
        
        modelContext.insert(newTask)
        dismiss()
    }
}

#Preview {
    CreateTaskView()
        .modelContainer(for: UserTask.self, inMemory: true)
}
