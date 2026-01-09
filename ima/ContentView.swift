//
//  ContentView.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Habit.title) private var habits: [Habit]
    @Query(sort: \UserTask.dateCreated) private var tasks: [UserTask]
    
    @State private var selectedTab: AppTab = .home
    @State private var showingCreateSheet = false
    
    private let dayChanged = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Background
            Color.black.ignoresSafeArea()
            AnimatedRadialBackground()
            
            // 2. Main Content
            VStack {
                switch selectedTab {
                case .home:
                    HomeView()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                case .habits:
                    HabitGroupView(habits: habits)
                        .accessibilityIdentifier("HabitList")
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                case .usertasks: // Make sure this matches your enum case name (usertasks vs tasks)
                    UserTaskGroupView(userTasks: tasks)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)

            // Adds invisible padding at the bottom equal to the footer's height
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
            
            // 3. Footer (Floats on top)
            NavFooterView(showingCreateSheet: $showingCreateSheet, selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showingCreateSheet) {
            if selectedTab == .habits {
                CreateHabitView()
            }
            else if selectedTab == .usertasks {
                CreateTaskView()
            }
        }
        .onAppear {
            Habit.resetHabitsIfNeeded(habits: habits)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Habit.resetHabitsIfNeeded(habits: habits)
            }
        }
        .onReceive(dayChanged) { _ in
            Habit.resetHabitsIfNeeded(habits: habits)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, UserTask.self], inMemory: true)
}
