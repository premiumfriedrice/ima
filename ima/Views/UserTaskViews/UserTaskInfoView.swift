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
    @Environment(\.appBackground) private var appBackground
    
    // 1. Bind to your UserTask model
    @Bindable var userTask: UserTask
    var readOnly: Bool = false

    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    @State private var newSubtaskTitle: String = ""
    @State private var currentDetent: PresentationDetent = .medium
    @FocusState private var isInputFocused: Bool

    // State for the calendar animation
    @State private var isCalendarVisible: Bool = false

    var body: some View {
        ZStack {

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                // MARK: - Header
                Group {
                    if readOnly {
                        Color.clear.frame(height: 0)
                    } else if isEditing {
                        HStack {
                            Text("EDITING")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .foregroundStyle(.white.opacity(0.4))

                            Spacer()

                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.snappy) {
                                    isEditing = false
                                    dismissKeyboard()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(
                                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        HStack {
                            // Complete button
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    userTask.isCompleted.toggle()
                                    userTask.dateCompleted = userTask.isCompleted ? Date() : nil
                                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                }
                            } label: {
                                Image(systemName: userTask.isCompleted ? "checkmark" : "circle")
                                    .font(.callout)
                                    .foregroundStyle(userTask.isCompleted ? .white : .white.opacity(0.6))
                                    .padding(10)
                                    .background(
                                        ZStack {
                                            if userTask.isCompleted {
                                                LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            } else {
                                                Color.white.opacity(0.1)
                                            }
                                        }
                                    )
                                    .clipShape(Circle())
                            }

                            Spacer()

                            // Edit button
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.snappy) {
                                    isEditing = true
                                    currentDetent = .large
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(10)
                                    .background(.white.opacity(0.1))
                                    .clipShape(Circle())
                            }

                            // Delete button
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.callout)
                                    .foregroundStyle(.red.opacity(0.8))
                                    .padding(10)
                                    .background(.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, readOnly ? 0 : 12)
                .background {
                    appBackground.ignoresSafeArea()
                }
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [appBackground, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 12)
                    .offset(y: 12)
                }
                .zIndex(1)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Hero Title
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TASK")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)
                            
                            if isEditing {
                                TextField("Task Title", text: $userTask.title, axis: .vertical)
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .lineLimit(1...3)
                            } else {
                                Text(userTask.title)
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }

                            if userTask.isCompleted, let completed = userTask.dateCompleted {
                                Text("Completed " + completed.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .kerning(1.0)
                                    .opacity(0.5)
                                    .foregroundStyle(.white)
                            }
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
                                Picker("Priority", selection: $userTask.priority) {
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
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
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
                                            .font(.subheadline)
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
                                    HStack(spacing: 5) {
                                        Button {
                                            withAnimation(.snappy) { isCalendarVisible.toggle() }
                                        } label: {
                                            Text(userTask.dueDate!.formatted(date: .abbreviated, time: .omitted))
                                                .font(.subheadline)
                                                .foregroundStyle(.white.opacity(0.8))
                                                .lineLimit(1)
                                                .layoutPriority(1)
                                                .padding(.vertical, 5)
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
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.6))
                                                .padding(5)
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
                            .padding(.trailing, 20)
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
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DETAILS")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .kerning(1.0)
                                .opacity(0.5)
                                .foregroundStyle(.white)

                            if isEditing {
                                TextField("Add notes, context, or descriptions...", text: $userTask.details, axis: .vertical)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.ultraThinMaterial.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.white.opacity(0.15), lineWidth: 1)
                                    }
                                    .lineLimit(4...10)
                                    .frame(minHeight: 120, alignment: .top)
                            } else {
                                Text(userTask.details.isEmpty ? "No details" : userTask.details)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(userTask.details.isEmpty ? 0.3 : 0.8))
                                    .padding(15)
                                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.ultraThinMaterial.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.white.opacity(0.15), lineWidth: 1)
                                    }
                            }
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
                            
                            VStack(spacing: 10) {
                                // 1. List of Subtasks
                                // We iterate over the object directly.
                                ForEach(userTask.subtasks) { subtask in
                                    HStack(spacing: 10) {
                                        // Checkbox
                                        Button {
                                            withAnimation(.snappy) {
                                                subtask.isCompleted.toggle()
                                                UIImpactFeedbackGenerator(style: subtask.isCompleted ? .medium : .light).impactOccurred()
                                            }
                                        } label: {
                                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 24))
                                                .foregroundStyle(subtask.isCompleted ? AnyShapeStyle(.green.gradient) : AnyShapeStyle(.white.opacity(0.3)))
                                        }
                                        
                                        if isEditing {
                                            TextField("Subtask", text: Bindable(subtask).title, axis: .vertical)
                                                .font(.subheadline)
                                                .strikethrough(subtask.isCompleted)
                                                .foregroundStyle(subtask.isCompleted ? .white.opacity(0.5) : .white)
                                                .lineLimit(1...3)
                                        } else {
                                            Text(subtask.title)
                                                .font(.subheadline)
                                                .strikethrough(subtask.isCompleted)
                                                .foregroundStyle(subtask.isCompleted ? .white.opacity(0.5) : .white)
                                        }

                                        Spacer()

                                        if isEditing {
                                            Button {
                                                withAnimation {
                                                    modelContext.delete(subtask)
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.caption2)
                                                    .foregroundStyle(.white.opacity(0.3))
                                                    .padding(5)
                                                    .background(.white.opacity(0.05))
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.ultraThinMaterial.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.white.opacity(0.15), lineWidth: 1)
                                    }
                                }
                                
                                // 2. Add Subtask Input
                                HStack(spacing: 10) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.3))
                                    
                                    TextField("Add a subtask...", text: $newSubtaskTitle, axis: .vertical)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .lineLimit(1...3)
                                        .focused($isInputFocused)
                                        .autocorrectionDisabled()
                                        .onChange(of: newSubtaskTitle) { _, newValue in
                                            if newValue.contains("\n") {
                                                newSubtaskTitle = newValue.replacingOccurrences(of: "\n", with: "")
                                                addSubtask()
                                            }
                                        }
                                    
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
                                .padding(15)
                                .background {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial.opacity(0.1))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        Spacer()
                        
                        // MARK: - Footer Info
                        Text("Created " + userTask.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 12)
                }
                .scrollIndicators(.hidden)
            }
            .foregroundStyle(.white)
                .presentationDetents([.medium, .large], selection: $currentDetent)
            .presentationDragIndicator(.hidden)
            .presentationBackground(appBackground)
            .presentationCornerRadius(40)
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
                        lineWidth: 3
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
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
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
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }

        withAnimation {
            let newSub = Subtask(title: newSubtaskTitle)
            userTask.subtasks.append(newSub)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

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
