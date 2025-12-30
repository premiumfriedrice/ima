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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // Assuming this is your custom view
            AnimatedRadial(color: .white.opacity(0.1), startPoint: .topLeading, endPoint: .topTrailing)
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
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
                    .accessibilityIdentifier("CloseInfoViewButton")
                    
                    Spacer()
                    
                    // Only Delete button needed for a generic Task
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
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            // Editable title
                            TextField("Task Title", text: $userTask.title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        
                        // MARK: - Due Date Section (Added)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("DUE DATE")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                // Toggle Logic:
                                // If userTask.dueDate is NOT nil, toggle is ON.
                                // If user sets ON, we give it Date(). If OFF, we set nil.
                                Toggle("", isOn: Binding(
                                    get: { userTask.dueDate != nil },
                                    set: { if $0 { userTask.dueDate = Date() } else { userTask.dueDate = nil } }
                                ))
                                .labelsHidden()
                                .tint(.blue)
                            }
                            
                            // Show Controls if Date Exists
                            if let currentDueDate = userTask.dueDate {
                                VStack(spacing: 16) {
                                    // 1. Smart Chips
                                    HStack(spacing: 12) {
                                        Button {
                                            userTask.dueDate = Date()
                                        } label: {
                                            Text("Today")
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundStyle(Calendar.current.isDateInToday(currentDueDate) ? .black : .white)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(Calendar.current.isDateInToday(currentDueDate) ? .white : .white.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                        
                                        Button {
                                            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                                                userTask.dueDate = tomorrow
                                            }
                                        } label: {
                                            Text("Tomorrow")
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundStyle(Calendar.current.isDateInTomorrow(currentDueDate) ? .black : .white)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(Calendar.current.isDateInTomorrow(currentDueDate) ? .white : .white.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // 2. Date Picker
                                    // We force unwrap or provide default because we are inside `if let`
                                    // But to bind, we use a custom binding to satisfy the type system.
                                    DatePicker("", selection: Binding(
                                        get: { userTask.dueDate ?? Date() },
                                        set: { userTask.dueDate = $0 }
                                    ), displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .colorScheme(.dark) // White text for dark mode
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(16)
                                .background(.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
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
                            
                            // 1. List of Existing Subtasks
                            VStack(spacing: 12) {
                                ForEach(userTask.subtasks) { subtask in
                                    SubTaskRowView(subtask: subtask) {
                                        // Delete Logic
                                        withAnimation {
                                            // Delete from context and the array updates automatically via relationship
                                            modelContext.delete(subtask)
                                        }
                                    }
                                }
                                
                                // 2. Add Subtask Input
                                HStack(spacing: 12) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskTitle)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white)
                                        .submitLabel(.done)
                                        .focused($isInputFocused)
                                        .onSubmit {
                                            addSubtask()
                                        }
                                    
                                    // Show arrow button only if typing
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
                        // Fixed: Removed the '$' from userTask.dateCreated
                        Text("Created " + userTask.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
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

// MARK: - SubTask Row Component
struct SubTaskRowView: View {
    @Bindable var subtask: Subtask
    var onDelete: () -> Void
    
    var body: some View {
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
            
            // Text
            TextField("Subtask", text: $subtask.title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .strikethrough(subtask.isCompleted)
                .foregroundStyle(subtask.isCompleted ? .white.opacity(0.5) : .white)
            
            Spacer()
            
            // Delete X
            Button {
                onDelete()
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
