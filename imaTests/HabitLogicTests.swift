//
//  HabitLogicTests.swift
//  imaTests
//
//  Created by Lloyd Derryk Mudanza Alba on 12/28/25.
//

import Testing
import Foundation
import SwiftData
@testable import ima

@Suite("Habit Logic Tests")
struct HabitLogicTests {
    
    @Test("Increment increases counts correctly")
    func incrementLogic() {
        let habit = Habit(title: "Code", frequencyCount: 1, frequencyUnit: .daily)
        
        #expect(habit.currentCount == 0)
        #expect(habit.totalCount == 0)
        
        habit.increment()
        
        #expect(habit.currentCount == 1)
        #expect(habit.totalCount == 1)
        #expect(habit.isFullyDone == true)
    }
    
    @Test("Increment does not increment counts when goal met")
    func incrementLogicGoalMet() {
        // Updated init to use 'currentCount'
        let habit = Habit(title: "Code", totalCount: 1, currentCount: 1, frequencyCount: 1, frequencyUnit: .daily)
        
        habit.increment()
        
        #expect(habit.currentCount == 1)
        #expect(habit.totalCount == 1)
    }
    
    @Test(".resetCurrentProgress() resets counts correctly (Undo)")
    func resetCurrentProgressLogic() {
        let habit = Habit(title: "Code", totalCount: 2, currentCount: 1, frequencyCount: 1, frequencyUnit: .daily)
        
        #expect(habit.currentCount == 1)
        #expect(habit.totalCount == 2)
        
        habit.resetCurrentProgress()
        
        #expect(habit.currentCount == 0)
        #expect(habit.totalCount == 1) // Total count reduces because this was an "Undo"
    }
    
    @Test(".resetForNewCycle() resets currentCount correctly")
    func resetForNewCycleLogic() {
        let habit = Habit(title: "Code", totalCount: 1, frequencyCount: 2, frequencyUnit: .daily)
        
        habit.increment()
        
        #expect(habit.currentCount == 1)
        #expect(habit.totalCount == 2)
        
        // This simulates a new day/week starting
        habit.resetForNewCycle()
        
        #expect(habit.currentCount == 0)
        #expect(habit.totalCount == 2) // Total count stays same because it's a new day
    }
    
    @Test("Progress calculation is accurate")
    func progressCalculation() {
        let habit = Habit(title: "Gym", frequencyCount: 4, frequencyUnit: .weekly)
        habit.currentCount = 2
        
        #expect(habit.progress == 0.5) // 2 out of 4 is 50%
        #expect(habit.isFullyDone == false)
        
        habit.currentCount = 4
        #expect(habit.progress == 1.0)
        #expect(habit.isFullyDone == true)
    }
}

@Suite("Habit Reset Logic Tests")
struct ResetLogicTests {
    // MARK: - Time Travel Tests
    @MainActor
    @Test("Habits reset when date moves to the next day")
    func testMidnightReset() {
        // 1. Setup: Create a habit and mark it done "Today"
        let habit = Habit(title: "Midnight Test", frequencyCount: 1, frequencyUnit: .daily)
        habit.increment()
        #expect(habit.currentCount == 1)
        
        // 2. Mock "Today" as the Last Reset Date
        let today = Date()
        UserDefaults.standard.set(today, forKey: "LastResetDate")
        
        // 3. Simulate Time Travel: Create a date for "Tomorrow"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // 4. Run the reset logic as if it is tomorrow
        Habit.resetHabitsIfNeeded(habits: [habit], asOf: tomorrow)
        
        // 5. Verify: Progress should be 0, but totalCount should stay 1
        #expect(habit.currentCount == 0)
        #expect(habit.totalCount == 1)
    }
    
    @MainActor
    @Test("Daily habits reset every time the calendar day changes")
    func testDailyResetLogic() {
        let habit = Habit(title: "Daily Meditation", frequencyCount: 1, frequencyUnit: .daily)
        habit.increment() // Now 1/1 done
        
        let calendar = Calendar.current
        // Create two consecutive days
        let monday = calendar.date(from: DateComponents(year: 2025, month: 12, day: 29))!
        let tuesday = calendar.date(from: DateComponents(year: 2025, month: 12, day: 30))!
        
        // Step 1: Simulate the last reset was on Monday
        UserDefaults.standard.set(monday, forKey: "LastResetDate")
        
        // Step 2: Run reset logic as if it is now Tuesday
        Habit.resetHabitsIfNeeded(habits: [habit], asOf: tuesday)
        
        // Result: Daily habit should be 0, but totalCount should be 1
        #expect(habit.currentCount == 0, "Daily habit should reset when moving to the next day")
        #expect(habit.totalCount == 1, "Lifetime stats should be preserved during a daily reset")
    }
    
    @MainActor
    @Test("Weekly habits reset only when the calendar week changes")
    func testWeeklyResetLogic() {
        let habit = Habit(title: "Weekly Gym", frequencyCount: 3, frequencyUnit: .weekly)
        habit.increment() // Now 1/3 done
        
        // 1. Setup "Current Date" (e.g., today)
        let today = Date()
        
        // 2. Setup "Last Reset Date" as 8 days ago (Definitely a different week)
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: today)!
        
        // 3. Simulate the last reset happened last week
        UserDefaults.standard.set(lastWeek, forKey: "LastResetDate")
        
        // 4. Run reset logic as of Today
        Habit.resetHabitsIfNeeded(habits: [habit], asOf: today)
        
        // Result: Should be 0 because a full week has definitely passed
        #expect(habit.currentCount == 0, "Weekly habit should reset when a new week begins")
    }
    
    @MainActor
    @Test("Monthly habits reset only on the first of the month")
    func testMonthlyResetLogic() {
        let habit = Habit(title: "Monthly Book", frequencyCount: 1, frequencyUnit: .monthly)
        habit.increment() // Now 1/1 done
        
        let calendar = Calendar.current
        let lastDayOfDec = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!
        let firstDayOfJan = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        
        // Step 1: Simulate last reset on New Year's Eve
        UserDefaults.standard.set(lastDayOfDec, forKey: "LastResetDate")
        
        // Step 2: Run reset logic as if it's New Year's Day
        Habit.resetHabitsIfNeeded(habits: [habit], asOf: firstDayOfJan)
        
        // Result: Progress should be 0
        #expect(habit.currentCount == 0, "Monthly habit should reset when the month changes")
    }
}
