//
//  Habit.swift
//  ima/Models
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
    var currentCount: Int
    var frequencyCount: Int
    var frequencyUnitRaw: String
    var dateCreated: Date
    
    // Computed property to handle the Enum conversion
    var frequencyUnit: FrequencyUnit {
        get { FrequencyUnit(rawValue: frequencyUnitRaw) ?? .daily }
        set { frequencyUnitRaw = newValue.rawValue }
    }

    var progress: Double {
        guard frequencyCount > 0 else { return 0.0 }
        return Double(currentCount) / Double(frequencyCount)
    }

    var isFullyDone: Bool {
        currentCount >= frequencyCount
    }

    var statusColor: Color {
        if isFullyDone {
            return .green
        } else if currentCount > 0 {
            return .orange
        } else {
            return .white.opacity(0.4)
        }
    }
    
    var completionHistory: [String: Int] = [:]

    init(
        title: String,
        totalCount: Int = 0,
        currentCount: Int = 0,
        frequencyCount: Int,
        frequencyUnit: FrequencyUnit
    ) {
        self.id = UUID()
        self.title = title
        self.totalCount = totalCount
        self.currentCount = currentCount
        self.frequencyCount = frequencyCount
        self.frequencyUnitRaw = frequencyUnit.rawValue
        self.dateCreated = Date()
    }
    
    // MARK: - Instance Methods
    
    func increment() {
        if !isFullyDone {
            currentCount += 1
            totalCount += 1
            
            // Log history for Calendar (We log the date it happened)
            let key = Date().formatted(.iso8601.year().month().day())
            completionHistory[key] = currentCount
        }
    }
    
    /// Called when the user wants to completely wipe progress (Undo button)
    func resetCurrentProgress() {
        if currentCount > 0 {
            totalCount -= currentCount // Undo the total count contribution
            currentCount = 0
        }
    }
    
    /// Called automatically by the system when the cycle (Day/Week/Month) flips
    func resetForNewCycle() {
        currentCount = 0
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
    
    // MARK: - Static Helpers (Context-Aware Reset)
    
    /// Checks the calendar and resets habits based on their specific frequency
    @MainActor
    static func resetHabitsIfNeeded(habits: [Habit], asOf currentDate: Date = Date()) {
        let calendar = Calendar.current
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        // 1. Only run logic if at least one day has passed since last check
        if !calendar.isDate(lastResetDate, inSameDayAs: currentDate) {
            print("Date change detected. Checking all habits for necessary resets...")
            
            withAnimation {
                for habit in habits {
                    let shouldReset: Bool
                    
                    switch habit.frequencyUnit {
                    case .daily:
                        // Always reset if the day changed
                        shouldReset = true
                        
                    case .weekly:
                        // Reset ONLY if the week changed (e.g. Sunday -> Monday)
                        shouldReset = !calendar.isDate(lastResetDate, equalTo: currentDate, toGranularity: .weekOfYear)
                        
                    case .monthly:
                        // Reset ONLY if the month changed (e.g. 31st -> 1st)
                        shouldReset = !calendar.isDate(lastResetDate, equalTo: currentDate, toGranularity: .month)
                    }
                    
                    if shouldReset {
                        habit.resetForNewCycle()
                    }
                }
            }
            
            // 2. Update the last reset date to "now"
            UserDefaults.standard.set(currentDate, forKey: "LastResetDate")
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
