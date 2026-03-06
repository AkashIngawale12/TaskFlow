//
//  Tag.swift
//  TaskFlow
//
//  Optional tags for tasks (e.g. #urgent, #waiting). Many-to-many with Task.
//

import Foundation
import SwiftData

@Model
final class Tag {

    // MARK: - Properties

    var id: UUID
    var name: String
    var createdAt: Date

    // MARK: - Init

    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

extension Tag: Identifiable {}
