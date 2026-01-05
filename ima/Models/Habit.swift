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

    // UPDATED: Always return green, but vary intensity/opacity in the View if needed
    var statusColor: Color {
        return .green
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
            
            let key = Date().formatted(.iso8601.year().month().day())
            completionHistory[key] = currentCount
        }
    }

    func decrement() {
        if currentCount > 0 {
            currentCount -= 1
            totalCount -= 1
            
            let key = Date().formatted(.iso8601.year().month().day())
            completionHistory[key] = currentCount
        }
    }
    
    func resetCurrentProgress() {
        if currentCount > 0 {
            totalCount -= currentCount
            currentCount = 0
        }
    }
    
    func resetForNewCycle() {
        currentCount = 0
    }
    
    // For Calendar - Uses opacity instead of different colors
    func colorFor(date: Date) -> Color {
        let key = date.formatted(.iso8601.year().month().day())
        let count = completionHistory[key] ?? 0
        
        if count >= frequencyCount {
            return .green // Full opacity
        } else if count > 0 {
            return .green.opacity(0.5) // Lower opacity for partial
        } else {
            return .white.opacity(0.05)
        }
    }
    
    // MARK: - Static Helpers
    @MainActor
    static func resetHabitsIfNeeded(habits: [Habit], asOf currentDate: Date = Date()) {
        let calendar = Calendar.current
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        if !calendar.isDate(lastResetDate, inSameDayAs: currentDate) {
            withAnimation {
                for habit in habits {
                    let shouldReset: Bool
                    switch habit.frequencyUnit {
                    case .daily: shouldReset = true
                    case .weekly: shouldReset = !calendar.isDate(lastResetDate, equalTo: currentDate, toGranularity: .weekOfYear)
                    case .monthly: shouldReset = !calendar.isDate(lastResetDate, equalTo: currentDate, toGranularity: .month)
                    }
                    if shouldReset { habit.resetForNewCycle() }
                }
            }
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
