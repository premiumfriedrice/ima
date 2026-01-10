//
//  UserTaskInfoView.swift
//  ima/Views/TaskViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct UserTaskInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 1. Bind to your UserTask model
    @Bindable var userTask: UserTask
    
    @State private var showingDeleteConfirmation = false
    @State private var newSubtaskTitle: String = ""
    @FocusState private var isInputFocused: Bool
    
    // State for the calendar animation
    @State private var isCalendarVisible: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, /*weight: .bold*/))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("CloseInfoViewButton")
                    
                    Spacer()
                    
                    // Delete button
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(12)
                            .background(.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(25)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Hero Title
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TASK")
                                .font(.system(.caption, design: .rounded))
//                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            // Editable title
                            TextField("Task Title", text: $userTask.title)
                                .font(.system(size: 36, /*weight: .bold,*/ design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        
                        // MARK: - Sentence Row (Priority & Due Date)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRIORITY and DUE DATE")
                                .font(.system(.caption, design: .rounded))
//                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                                .padding(.leading, 25)
                            
                            // Row 1: The entire sentence on one line
                            HStack(spacing: 0) {
                                // 1. Priority Picker
                                Picker("Priority", selection: $userTask.priority) {
                                    ForEach(TaskPriority.allCases) { p in
                                        Text("\(p.title)")
                                            .font(.system(size: 16, /*weight: .bold,*/ design: .rounded))
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
                                                colors: [userTask.priority.color],
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
                                    .font(.system(size: 18, /*weight: .bold,*/ design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(0)
                                    .lineLimit(1)
                                    .layoutPriority(1)
                                
                                // 3. Date Logic
                                if userTask.dueDate == nil {
                                    // State A: "no date"
                                    Button {
                                        withAnimation(.snappy) {
                                            userTask.dueDate = Date()
                                            isCalendarVisible = true
                                        }
                                    } label: {
                                        Text("no date")
                                            .font(.system(size: 16, /*weight: .bold,*/ design: .rounded))
                                            .foregroundStyle(.white.opacity(0.8))
                                            .lineLimit(1)
                                            .layoutPriority(1)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                            )
                                    }
                                    .padding(.leading, 8)
                                    
                                } else {
                                    // State B: "Dec 30, 2025" + Close
                                    HStack(spacing: 6) {
                                        Button {
                                            withAnimation(.snappy) { isCalendarVisible.toggle() }
                                        } label: {
                                            Text(userTask.dueDate!.formatted(date: .abbreviated, time: .omitted))
                                                .font(.system(size: 16, /*weight: .bold,*/ design: .rounded))
                                                .foregroundStyle(.white.opacity(0.8))
                                                .lineLimit(1)
                                                .layoutPriority(1)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 10)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(isCalendarVisible ? .white.opacity(1) : .white.opacity(0.3), lineWidth: 1.5)
                                                )
                                        }
                                        .padding(.leading, 8)
                                        
                                        // Close Button (Remove Date)
                                        Button {
                                            withAnimation(.snappy) {
                                                userTask.dueDate = nil
                                                isCalendarVisible = false
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, /*weight: .bold*/))
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
                            if userTask.dueDate != nil && isCalendarVisible {
                                DatePicker("", selection: Binding(
                                    get: { userTask.dueDate ?? Date() },
                                    set: { userTask.dueDate = $0 }
                                ), displayedComponents: [.date])
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DETAILS")
                                .font(.system(.caption, design: .rounded))
//                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            TextField("Add notes, context, or descriptions...", text: $userTask.details, axis: .vertical)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
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
                                .font(.system(.caption, design: .rounded))
//                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 12) {
                                // 1. List of Subtasks
                                // We iterate over the object directly.
                                ForEach(userTask.subtasks) { subtask in
                                    HStack(spacing: 12) {
                                        // Checkbox
                                        Button {
                                            withAnimation(.snappy) {
                                                subtask.isCompleted.toggle()
                                            }
                                        } label: {
                                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 24))
                                                .foregroundStyle(subtask.isCompleted ? .green : .white.opacity(0.3))
                                        }
                                        
                                        // Text Input (Editable)
                                        // Bindable(subtask) allows us to create a binding to a SwiftData object's property inside a loop
                                        TextField("Subtask", text: Bindable(subtask).title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .strikethrough(subtask.isCompleted)
                                            .foregroundStyle(subtask.isCompleted ? .white.opacity(0.5) : .white)
                                        
                                        Spacer()
                                        
                                        // Delete Button
                                        Button {
                                            withAnimation {
                                                modelContext.delete(subtask)
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12, /*weight: .bold*/))
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
                                    Image(systemName: "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.3))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskTitle)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white)
                                        .submitLabel(.done)
                                        .focused($isInputFocused)
                                        .onSubmit { addSubtask() }
                                        .autocorrectionDisabled()
                                    
                                    if !newSubtaskTitle.isEmpty {
                                        Button {
                                            addSubtask()
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
                        
                        // MARK: - Footer Info
                        Text("Created " + userTask.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(.caption, design: .rounded))
//                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
            .foregroundStyle(.white)
            // Shiny Border Overlay
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
        .confirmationDialog(
            "Are you sure you want to delete '\(userTask.title)'?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Task", role: .destructive) {
                dismiss()
                Task {
                    try? await Task.sleep(for: .seconds(0.35))
                    modelContext.delete(userTask)
                }
            }
            Button("Cancel") { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Logic
    
    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        withAnimation {
            let newSub = Subtask(title: newSubtaskTitle)
            userTask.subtasks.append(newSub)
            
            // Reset input
            newSubtaskTitle = ""
            isInputFocused = false
        }
    }
}

#Preview {
    let task = UserTask(
        title: "Finish Project",
        details: "Finish ima and get it to the app store",
        priority: .medium,
        subtasks: [Subtask(title: "Finish implementing user tasks")]
    )
    
    UserTaskInfoView(userTask: task)
}
