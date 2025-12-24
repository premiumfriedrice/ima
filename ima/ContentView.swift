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
                Text("Today's Work")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    if selectedTab == 0 {
                        ScrollView {
                            VStack{
                                HabitGroupView(habits: habits, onAddTap: addSampleHabit)
                                
                                Spacer()
                                
//                                Text("Tasks")
//                                    .font(.title2)
//                                    .foregroundStyle(.white)
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading)
//                                VStack(spacing: 16) {
//                                    ForEach(habits) { habit in
//                                        HabitCardView(habit: habit)
//                                    }
//                                }
//                                .padding(.top, 10)
//                                .padding(.bottom, 10)
                                
                            }
                            .padding(.bottom, 100)
                        }
                    } else {
                        Text("Progress Stats Coming Soon")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
            }
            
            PillMenuBar(selectedIndex: $selectedTab, tabs: ["Today", "Progress"], baseColor: .gray)
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
    
    private func addSampleHabit() {
        // Create different sample data
        let newHabit = Habit(title: "Pray", frequencyCount: 5, frequencyUnit: .daily)
        modelContext.insert(newHabit)
        
        let anotherHabit = Habit(title: "LeetCode", frequencyCount: 2, frequencyUnit: .daily)
        modelContext.insert(anotherHabit)
        
        let yetAnotherHabit = Habit(title: "Workout", frequencyCount: 3, frequencyUnit: .weekly)
        modelContext.insert(yetAnotherHabit)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
