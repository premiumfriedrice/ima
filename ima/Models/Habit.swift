//
//  Item.swift
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
    
    var isFullyDone: Bool {
        if frequencyUnit == .daily {
            // Daily habits depend on the daily reset
            return countDoneToday >= dailyGoal
        } else {
            // Weekly/Monthly habits stay done once the total hits the goal
            return totalCount >= frequencyCount
        }
    }

    var statusColor: Color {
        if isFullyDone {
            return .green
        } else if countDoneToday > 0 || totalCount > 0 {
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
    
/// Logic to determine if the habit should reset based on its frequency
//    func checkAndResetIfNeeded() {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        let shouldReset: Bool
//        
//        switch frequencyUnit {
//        case .daily:
//            shouldReset = !calendar.isDate(dateLastReset, inSameDayAs: now)
//        case .weekly:
//            shouldReset = !calendar.isDate(dateLastReset, equalTo: now, toGranularity: .weekOfYear)
//        case .monthly:
//            shouldReset = !calendar.isDate(dateLastReset, equalTo: now, toGranularity: .month)
//        }
//        
//        if shouldReset {
//            resetProgress()
//        }
//    }
//    
    func resetProgress() {
        totalCount -= countDoneToday
        countDoneToday = 0
        dateLastReset = Date()
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
}

private func calendarDay(for date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}

enum FrequencyUnit: String, Codable, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
}
