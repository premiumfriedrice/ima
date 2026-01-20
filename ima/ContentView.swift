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
            // 1. Background (Global)
            Color.clear.ignoresSafeArea()
//            AnimatedRadialBackground()
            
            // 2. Main Content (Swipeable)
            TabView(selection: $selectedTab) {
                // Page 1: Home
                HomeView()
                    .tag(AppTab.home)
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
                
                // Page 2: Habits
                HabitGroupView(habits: habits)
                    .accessibilityIdentifier("HabitList")
                    .tag(AppTab.habits)
                    // Added bottom inset for footer space
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
                
                // Page 3: User Tasks
                UserTaskGroupView(userTasks: tasks)
                    .tag(AppTab.usertasks)
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
                
                // Page 4: Profile
                ProfileView()
                    .tag(AppTab.profile)
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // FIXED: Ignore ALL safe areas so pages go behind the Notch/Dynamic Island
            .ignoresSafeArea()
            
            // 3. Footer (Floats on top)
            NavFooterView(showingCreateSheet: $showingCreateSheet, selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showingCreateSheet) {
            if selectedTab == .habits {
                CreateHabitView()
            } else if selectedTab == .usertasks {
                CreateTaskView()
            } else {
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
