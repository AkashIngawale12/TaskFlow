//
//  Category.swift
//  TaskFlow
//
//  SwiftData model for task categories (e.g. Work, Personal, Health).
//

import Foundation
import SwiftData

@Model
final class Category {

    // MARK: - Properties

    var id: UUID
    var name: String
    var createdAt: Date
    /// Hex color (e.g. "0A84FF"); nil = use default.
    var colorHex: String?
    /// SF Symbol name (e.g. "briefcase.fill"); nil = folder.fill.
    var iconName: String?

    @Relationship(deleteRule: .nullify, inverse: \Task.category)
    var tasks: [Task]?

    // MARK: - Init

    init(id: UUID = UUID(), name: String, colorHex: String? = nil, iconName: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = createdAt
    }
}

extension Category: Identifiable {}
