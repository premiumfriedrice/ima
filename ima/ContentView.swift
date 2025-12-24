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
    @Query(sort: \Habit.title) private var habits: [Habit]
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            AnimatedRadialBackground()
            
            VStack {
                VStack {
                    if selectedTab == 0 {
                        VStack{
                            HabitGroupView(habits: habits)
                        }
                        .padding(.bottom, 100)
                    } else {
                        Text("Tasks Coming Soon")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
            }
            
            PillMenuBar(selectedIndex: $selectedTab, tabs: ["Habits", "Tasks"], baseColor: .gray)
        }
        .onAppear {
            resetHabitsIfNeeded()
        }
    }
    
    
    func resetHabitsIfNeeded() {
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        if !Calendar.current.isDateInToday(lastResetDate) {
            for habit in habits {
                habit.countDoneToday = 0 // Reset daily count
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
