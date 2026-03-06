//
//  TaskFilter.swift
//  TaskFlow
//
//  Filter options for the task list (All, Today, Overdue, Completed).
//

import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {

    // MARK: - Cases

    case all = "All"
    case today = "Today"
    case overdue = "Overdue"
    case completed = "Completed"

    var id: String { rawValue }
}
