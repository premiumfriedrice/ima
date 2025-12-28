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
    @State private var selectedTab = 0
    
    private let dayChanged = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.black).ignoresSafeArea()
            AnimatedRadialBackground()
            VStack {
                VStack {
                    if selectedTab == 0 {
                        VStack{
                            HabitGroupView(habits: habits)
                        }
                    } else {
                        Text("Tasks Coming Soon")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .kerning(1.0)
                            .opacity(0.5)
                            .foregroundStyle(.white)
                    }
                }
                
            }
            
        }
        .onAppear {
            Habit.resetHabitsIfNeeded(habits: habits)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in // iOS 17+ Syntax
            if newPhase == .active {
                Habit.resetHabitsIfNeeded(habits: habits)
            }
        }
        .onReceive(dayChanged) { _ in
            Habit.resetHabitsIfNeeded(habits: habits)
        }
//        .preferredColorScheme(.dark)
    }
    
    func resetHabitsIfNeeded() {
            let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
            
            if !Calendar.current.isDateInToday(lastResetDate) {
                print("Resetting habits for the new day...")
                withAnimation {
                    for habit in habits {
                        habit.resetProgress()
                    }
                }
                UserDefaults.standard.set(Date(), forKey: "LastResetDate")
            }
        }
    
    func debugPrintHabits() {
        // 1. Create a FetchDescriptor to find all Habits
        let descriptor = FetchDescriptor<Habit>()
        
        do {
            // 2. Execute the fetch via the context
            let allHabits = try modelContext.fetch(descriptor)
            
            print("--- ima Database Debug ---")
            if allHabits.isEmpty {
                print("The database is currently empty.")
            } else {
                for habit in allHabits {
                    print("""
                    ID: \(habit.id)
                    Title: \(habit.title)
                    Done Today: \(habit.countDoneToday)/\(habit.dailyGoal)
                    Total: \(habit.totalCount)
                    -----------------------
                    """)
                }
            }
        } catch {
            print("Failed to fetch habits: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
