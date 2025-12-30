//
//  UserTask.swift
//  ima/Models
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Priority Enum
enum TaskPriority: Int, Identifiable, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

// MARK: - Subtask Model
@Model
final class Subtask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    
    // Inverse relationship: Points back to the parent Task
    // Optional because a Subtask is technically created before it's attached
    var userTask: UserTask?
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - Main Task Model
@Model
final class UserTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var dateCreated: Date
    
    var details: String
    var dueDate: Date?
    var priority: TaskPriority
    
    // Relationship: Deletes subtasks when Task is deleted
    // 'inverse' points to the variable name in Subtask
    @Relationship(deleteRule: .cascade, inverse: \Subtask.userTask)
    var subtasks: [Subtask] = []
    
    init(
        title: String,
        isCompleted: Bool = false,
        dateCreated: Date = .now,
        details: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        subtasks: [Subtask] = []
    ) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.details = details
        self.dueDate = dueDate
        self.priority = priority
        self.subtasks = subtasks
    }
}
