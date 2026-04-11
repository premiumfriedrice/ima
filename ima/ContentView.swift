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
    
    @AppStorage("appBackground") private var backgroundRaw: String = AppBackground.pureBlack.rawValue

    @State private var selectedTab: AppTab = .home
    
    private let dayChanged = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    private var bgColor: Color {
        AppBackground(rawValue: backgroundRaw)?.color ?? .black
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Background (Global)
            bgColor.ignoresSafeArea()
//            AnimatedRadialBackground()
            
            // 2. Main Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .habits:
                    HabitGroupView(habits: habits)
                        .accessibilityIdentifier("HabitList")
                case .usertasks:
                    UserTaskGroupView(userTasks: tasks)
                case .profile:
                    ProfileView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selectedTab != .home {
                    Color.clear.frame(height: 80)
                }
            }
            
            // 3. Footer (Floats on top)
            NavFooterView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
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
        .environment(\.appBackground, bgColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, UserTask.self], inMemory: true)
}
