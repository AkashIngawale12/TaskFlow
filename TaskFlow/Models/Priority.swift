//
//  Priority.swift
//  TaskFlow
//
//  Task priority levels for filtering and sorting.
//

import Foundation

/// Priority levels for tasks. Stored as Int in SwiftData for stable ordering.
enum Priority: Int, CaseIterable, Codable, Sendable {

    // MARK: - Cases

    case low = 0
    case medium = 1
    case high = 2

    // MARK: - Display

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var sortOrder: Int { rawValue }
}
