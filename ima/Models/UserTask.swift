//
//  UserTask.swift
//  ima/Models
//
//  Created by Lloyd Derryk Mudanza Alba on 12/29/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class UserTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}

// TODO:
// Implement subtasks
// Implement description
// Implement Due date
// Implement priority
