//
//  Habit.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var title: String
    var totalCount: Int
    var countDoneToday: Int
    var frequencyCount: Int
    var frequencyUnitRaw: String
    var dateCreated: Date
    var dateLastReset: Date
    
    // Computed property to handle the Enum conversion
    var frequencyUnit: FrequencyUnit {
        get { FrequencyUnit(rawValue: frequencyUnitRaw) ?? .daily }
        set { frequencyUnitRaw = newValue.rawValue }
    }

    // Defines if the habit is "finished" for today
    var dailyGoal: Int {
        frequencyUnit == .daily ? frequencyCount : 1
    }

    // A helper property to make View code cleaner
    var frequency: (count: Int, unit: FrequencyUnit) {
        (frequencyCount, frequencyUnit)
    }
    
    var statusColor: Color {
        let isDone = countDoneToday >= dailyGoal
        if isDone {
            return .green
        } else if countDoneToday > 0 {
            return .orange
        } else {
            return .white.opacity(0.4)
        }
    }
    
    var completionHistory: [String: Int] = [:]

    init(title: String, totalCount: Int = 0, countDoneToday: Int = 0, frequencyCount: Int, frequencyUnit: FrequencyUnit) {
        self.id = UUID()
        self.title = title
        self.totalCount = totalCount
        self.countDoneToday = countDoneToday
        self.frequencyCount = frequencyCount
        self.frequencyUnitRaw = frequencyUnit.rawValue
        self.dateCreated = Date()
        self.dateLastReset = Date()
    }
    
    // MARK: - Instance Methods
    
    func increment() {
        if countDoneToday < dailyGoal {
            countDoneToday += 1
            totalCount += 1
            
            // Log history for Calendar
            let key = Date().formatted(.iso8601.year().month().day())
            completionHistory[key] = countDoneToday
        }
    }
    
    /// Called when the user wants to completely wipe progress (Undo)
    func resetProgress() {
        if countDoneToday > 0 {
            totalCount -= countDoneToday // Undo the total count contribution
            countDoneToday = 0
        }
    }
    
    /// Called automatically by the system for a new day (Keeps Total Count!)
    func resetForNewDay() {
        countDoneToday = 0
        // We do NOT subtract from totalCount here, preserving lifetime stats
    }
    
    // For Calendar
    func colorFor(date: Date) -> Color {
        let key = date.formatted(.iso8601.year().month().day())
        let count = completionHistory[key] ?? 0
        
        if count >= frequencyCount {
            return .green
        } else if count > 0 {
            return .orange
        } else {
            return .white.opacity(0.1)
        }
    }
    
    // MARK: - Static Helpers (The Logic You Asked For)
    
    /// Checks if it's a new day and resets all provided habits
    @MainActor
    static func resetHabitsIfNeeded(habits: [Habit]) {
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        if !Calendar.current.isDateInToday(lastResetDate) {
            print("Resetting habits for the new day...")
            
            withAnimation {
                for habit in habits {
                    // Only reset daily habits automatically
                    if habit.frequencyUnit == .daily {
                        habit.resetForNewDay()
                    }
                }
            }
            
            UserDefaults.standard.set(Date(), forKey: "LastResetDate")
        }
    }
}

private func calendarDay(for date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}

enum FrequencyUnit: String, Codable, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
}
