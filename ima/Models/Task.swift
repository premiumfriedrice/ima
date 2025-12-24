//
//  Task.swift
//  ima
//
//  Created by Lloyd Derryk Mudanza Alba on 12/23/25.
//

import Foundation
import SwiftData

@Model final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false

    init(title: String, dueDate: Date) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = false
    }
}
