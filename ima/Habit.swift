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
    var frequencyUnitRaw: String // Store enum as String for SwiftData compatibility
    
    var frequencyUnit: FrequencyUnit {
        get { FrequencyUnit(rawValue: frequencyUnitRaw) ?? .daily }
        set { frequencyUnitRaw = newValue.rawValue }
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
