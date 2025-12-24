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
                return .white.opacity(0.3)
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
    }
    
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
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
