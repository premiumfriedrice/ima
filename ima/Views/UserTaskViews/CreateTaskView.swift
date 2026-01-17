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
    @State private var isCalendarVisible: Bool = false
    
    @State private var tempSubtasks: [String] = []
    @State private var newSubtaskInput: String = ""
    @State private var newDetailsInput: String = ""
    
    @FocusState private var isInputFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 20)
                
                // MARK: - Header
                HStack {
                    Spacer()
                    
                    Button {
                        createTask()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(!title.isEmpty ? .white : .white.opacity(0.3))
                            .frame(width: 50, height: 50) // Fixed size for a perfect circle
                            .background(
                                ZStack {
                                    if !title.isEmpty {
                                        // Gradient when active
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        // Subtle gray background when disabled
                                        Color.white.opacity(0.1)
                                    }
                                }
                            )
                            .clipShape(Circle())
                            // Add a glow when active
                            .shadow(color: !title.isEmpty ? Color.blue.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
                            .animation(.smooth, value: !title.isEmpty)
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("CreateUserTaskButton")
                }
                .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TASK")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("e.g., Shopping, Laundry", text: $title)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .submitLabel(.next)
                                .focused($isTitleFocused)
                                .autocorrectionDisabled()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                        // MARK: - Sentence Row (Priority & Due Date)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PRIORITY and DUE DATE")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                                .padding(.leading, 25)
                            
                            // Row 1: The entire sentence on one line
                            HStack(spacing: 0) {
                                // 1. Priority Picker
                                Picker("Priority", selection: $priority) {
                                    ForEach(TaskPriority.allCases) { p in
                                        Text("\(p.title)")
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                            .tag(p)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 96, height: 84)
                                .compositingGroup()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [priority.color],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                        .frame(width: 78, height: 34)
                                        .allowsHitTesting(false)
                                }
                                
                                // 2. Connecting text
                                Text("priority due")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(0)
                                    .lineLimit(1)
                                    .layoutPriority(1)
                                // 3. Date Logic
                                if !hasDueDate {
                                    // State A: "no date"
                                    Button {
                                        withAnimation(.snappy) {
                                            hasDueDate = true
                                            isCalendarVisible = true
                                            dueDate = Date()
                                        }
                                    } label: {
                                        Text("no date")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.8))
                                            .lineLimit(1)
                                            .layoutPriority(1)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 8)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                            )
                                    }
                                    .padding(.leading, 8)
                                    
                                }
                                else {
                                    // State B: "Dec 30, 2025" + Close
                                    HStack(spacing: 5) {
                                        Button {
                                            withAnimation(.snappy) { isCalendarVisible.toggle() }
                                        } label: {
                                            Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                                .font(.subheadline)
                                                .foregroundStyle(.white.opacity(0.8))
                                                .lineLimit(1)
                                                .layoutPriority(1)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 8)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(isCalendarVisible ? .white.opacity(1) : .white.opacity(0.3), lineWidth: 1.5)
                                                )
                                        }
                                        .padding(.leading, 8)
                                        // Close Button
                                        Button {
                                            withAnimation(.snappy) {
                                                hasDueDate = false
                                                isCalendarVisible = false
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.6))
                                                .padding(6)
                                                .background(.white.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                                
                            }
                            // 1. Force the HStack to fill width, but align content Left
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // 2. Add normal margin
                            .padding(.leading, 20)
                            // 3. Reserve extra space on the right (25 normal + 20 buffer = 45pt empty space)
                            .padding(.trailing, 25)
                            .padding(.vertical, -10)
                            
                            // Row 2: The Calendar
                            if hasDueDate && isCalendarVisible {
                                DatePicker("", selection: $dueDate, displayedComponents: [.date])
                                    .datePickerStyle(.graphical)
                                    .colorScheme(.dark)
                                    .tint(.white)
                                    .padding()
                                    .background(.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 25)
                            }
                        }

                        // MARK: - Details Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DETAILS")
                                .font(.footnote)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("Add notes, context, or descriptions...", text: $newDetailsInput, axis: .vertical)
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(16)
                                .background(.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .lineLimit(3...6)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 25)

                        // MARK: - Subtasks Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("SUBTASKS")
                                .font(.caption2)
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
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Button { deleteTempSubtask(at: index) } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption2)
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
                                    Image(systemName: "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.3))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskInput)
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                        .submitLabel(.done)
                                        .focused($isInputFocused)
                                        .onSubmit { addTempSubtask() }
                                        .autocorrectionDisabled()
                                    
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
            .scrollIndicators(.hidden)
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
