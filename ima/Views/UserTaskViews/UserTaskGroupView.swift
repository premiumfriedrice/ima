//
//  UserTaskGroupView.swift
//  ima/Views/UserTaskViews
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import SwiftUI
import SwiftData

struct UserTaskGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appBackground) private var appBackground

    var userTasks: [UserTask]
    
    // State for the sheet
    @State private var selectedTask: UserTask?
    
    // 1. State variables for collapsing sections
    @State private var isHighPriorityExpanded = true
    @State private var isMediumPriorityExpanded = true
    @State private var isLowPriorityExpanded = true
    @State private var showingCreate = false
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    if userTasks.isEmpty {
                        // Empty State
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            VStack {
                                Text("No Tasks Yet")
                                    .font(.title2)
                                
                                Text("Tap the + button to create your first task.")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 40)
                        .font(.caption)
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            
                            Color.clear.frame(height: 0)
                            
                            // MARK: - High Priority
                            if !highPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "High Priority",
                                    subtitle: "\(highPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red,
                                    isExpanded: isHighPriorityExpanded, // Pass state
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle()) // Makes entire header tappable
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isHighPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    // Wrap content in if-check
                                    if isHighPriorityExpanded {
                                        ForEach(highPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Medium Priority
                            if !mediumPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Medium Priority",
                                    subtitle: "\(mediumPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .yellow,
                                    isExpanded: isMediumPriorityExpanded,
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isMediumPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isMediumPriorityExpanded {
                                        ForEach(mediumPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Low Priority
                            if !lowPriorityTasks.isEmpty {
                                Section(header: SectionHeader(
                                    title: "Low Priority",
                                    subtitle: "\(lowPriorityTasks.count) TASKS",
                                    icon: "exclamationmark.circle.fill",
                                    color: .gray,
                                    isExpanded: isLowPriorityExpanded,
                                    coordinateSpace: "taskScroll"
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        isLowPriorityExpanded.toggle()
                                    }
                                }
                                ) {
                                    if isLowPriorityExpanded {
                                        ForEach(lowPriorityTasks) { task in
                                            UserTaskCardView(task: task)
                                                .onTapGesture { UIImpactFeedbackGenerator(style: .light).impactOccurred(); selectedTask = task }
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }

                            // MARK: - Archive Card
                            if !completedTasks.isEmpty {
                                NavigationLink {
                                    TaskArchiveView(tasks: completedTasks)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "archivebox")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.5))

                                        Text("Archive")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.5))

                                        Spacer()

                                        Text("\(completedTasks.count)")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.4))

                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.3))
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
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }
                        }
                        .padding(.bottom, 200)
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "taskScroll")
                
                // MARK: - STICKY HEADER
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack {
                        Text("Tasks")
                            .foregroundStyle(.white)
                            .font(.title)

                        Spacer()

                        Button { showingCreate = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(10)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .background {
                        ZStack {
                            appBackground
                        }
                        .ignoresSafeArea(edges: .top)
                    }
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
        }
        .sheet(isPresented: $showingCreate) {
            CreateTaskView()
        }
        .background(appBackground)
        .navigationBarHidden(true)
        }
    }
    
    // MARK: - Filtering Logic
    
    private var highPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .high && !$0.isCompleted }
    }
    
    private var mediumPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .medium && !$0.isCompleted }
    }
    
    private var lowPriorityTasks: [UserTask] {
        userTasks.filter { $0.priority == .low && !$0.isCompleted }
    }
    
    private var completedTasks: [UserTask] {
        userTasks.filter { $0.isCompleted }
    }
}

#Preview {
    let tasks = [
        UserTask(title: "Active Task", details: "Do this", priority: .high),
        UserTask(title: "Done Task", isCompleted: true, details: "Did this", priority: .medium)
    ]
    
    ZStack {
        Color(.black).ignoresSafeArea()
        UserTaskGroupView(userTasks: tasks)
    }
}
