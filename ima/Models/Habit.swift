//
//  Item.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/22/25.
//

import Foundation
import SwiftData

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

    init(title: String, totalCount: Int = 0, countDoneToday: Int = 0, frequencyCount: Int, frequencyUnit: FrequencyUnit) {
        self.id = UUID()
        self.title = title
        self.totalCount = totalCount
        self.countDoneToday = countDoneToday
        self.frequencyCount = frequencyCount
        self.frequencyUnitRaw = frequencyUnit.rawValue
    }
}

enum FrequencyUnit: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
