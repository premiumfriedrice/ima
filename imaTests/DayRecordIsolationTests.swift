//
//  DayRecordIsolationTests.swift
//  imaTests
//
//  Tests that daily records are isolated — modifying today's habit
//  does not affect what past days display.
//

import Testing
import Foundation
@testable import ima

@Suite("Day Record Isolation Tests")
struct DayRecordIsolationTests {

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    private func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }

    // MARK: - Core Isolation

    @Test("Yesterday's record is not affected by today's increment")
    func yesterdayUnaffectedByTodayIncrement() {
        let habit = Habit(title: "Meditate", frequencyCount: 3, frequencyUnit: .daily)

        // Simulate yesterday: increment twice
        let yesterdayKey = dateKey(for: yesterday())
        habit.completionHistory[yesterdayKey] = 2

        // Simulate today: reset and increment once
        habit.resetForNewCycle()
        habit.increment() // currentCount = 1, today's key = 1

        // Yesterday's record should still be 2
        let recordedYesterday = habit.completionHistory[yesterdayKey] ?? 0
        #expect(recordedYesterday == 2, "Yesterday's count should remain 2, got \(recordedYesterday)")

        // Today's record should be 1
        let todayKey = dateKey(for: Date())
        let recordedToday = habit.completionHistory[todayKey] ?? 0
        #expect(recordedToday == 1, "Today's count should be 1, got \(recordedToday)")
    }

    @Test("Past day completion status reads from history, not currentCount")
    func pastDayReadsFromHistory() {
        let habit = Habit(title: "Exercise", frequencyCount: 2, frequencyUnit: .daily)

        // Yesterday was completed (2/2)
        let yesterdayKey = dateKey(for: yesterday())
        habit.completionHistory[yesterdayKey] = 2

        // Today is fresh (0/2)
        habit.currentCount = 0

        // Past day should show as completed (from history)
        let pastCount = habit.completionHistory[yesterdayKey] ?? 0
        #expect(pastCount >= habit.frequencyCount, "Yesterday should show as completed from history")

        // Today should show as not completed (from currentCount)
        #expect(habit.currentCount < habit.frequencyCount, "Today should not be completed")
    }

    @Test("Decrementing today does not change yesterday's record")
    func decrementDoesNotAffectYesterday() {
        let habit = Habit(title: "Read", frequencyCount: 3, frequencyUnit: .daily)

        // Yesterday: completed 3/3
        let yesterdayKey = dateKey(for: yesterday())
        habit.completionHistory[yesterdayKey] = 3

        // Today: increment then decrement
        habit.resetForNewCycle()
        habit.increment()
        habit.increment()
        habit.decrement()

        // Yesterday untouched
        #expect(habit.completionHistory[yesterdayKey] == 3, "Yesterday should still be 3")

        // Today should be 1
        let todayKey = dateKey(for: Date())
        #expect(habit.completionHistory[todayKey] == 1, "Today should be 1 after increment-increment-decrement")
    }

    // MARK: - Weekly Isolation

    @Test("Weekly habit: this week's record is isolated from last week")
    func weeklyIsolation() {
        let habit = Habit(title: "Gym", frequencyCount: 3, frequencyUnit: .weekly)

        // Last week: completed 3/3 on a day last week
        let lastWeekDay = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        let lastWeekKey = dateKey(for: lastWeekDay)
        habit.completionHistory[lastWeekKey] = 3

        // This week: fresh start
        habit.resetForNewCycle()
        habit.increment()

        // Last week's record should still be 3
        #expect(habit.completionHistory[lastWeekKey] == 3, "Last week's record should be unchanged")

        // This week (today) should be 1
        let todayKey = dateKey(for: Date())
        #expect(habit.completionHistory[todayKey] == 1, "This week should show 1")
    }

    // MARK: - Multiple Days

    @Test("Multiple days maintain independent records")
    func multipleDaysIndependent() {
        let habit = Habit(title: "Journal", frequencyCount: 1, frequencyUnit: .daily)

        let calendar = Calendar.current
        let today = Date()

        // Simulate 3 days of history
        for daysAgo in (1...3).reversed() {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let key = dateKey(for: day)
            habit.completionHistory[key] = daysAgo % 2 == 0 ? 1 : 0 // alternating complete/incomplete
        }

        // Today: increment
        habit.currentCount = 0
        habit.increment()

        // Verify each day independently
        for daysAgo in 1...3 {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let key = dateKey(for: day)
            let expected = daysAgo % 2 == 0 ? 1 : 0
            let actual = habit.completionHistory[key] ?? 0
            #expect(actual == expected, "Day -\(daysAgo) should be \(expected), got \(actual)")
        }

        // Today should be 1
        let todayKey = dateKey(for: today)
        #expect(habit.completionHistory[todayKey] == 1, "Today should be 1")
    }

    // MARK: - Edge Cases

    @Test("Day with no history entry returns 0")
    func noHistoryReturnsZero() {
        let habit = Habit(title: "Stretch", frequencyCount: 2, frequencyUnit: .daily)

        // A day with no entry
        let randomPastDay = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let key = dateKey(for: randomPastDay)

        #expect(habit.completionHistory[key] == nil, "No entry should exist for a day 30 days ago")
        #expect((habit.completionHistory[key] ?? 0) == 0, "Default should be 0")
    }

    @Test("Resetting for new cycle does not clear completion history")
    func resetPreservesHistory() {
        let habit = Habit(title: "Code", frequencyCount: 2, frequencyUnit: .daily)

        // Today: complete
        habit.increment()
        habit.increment()
        let todayKey = dateKey(for: Date())
        #expect(habit.completionHistory[todayKey] == 2)

        // Reset for new day
        habit.resetForNewCycle()

        // History should still have today's record
        #expect(habit.completionHistory[todayKey] == 2, "Reset should not clear history")
        #expect(habit.currentCount == 0, "currentCount should be 0 after reset")
    }
}
