//
//  Task.swift
//  TaskFlow
//
//  SwiftData model for tasks with due date, priority, and category.
//

import Foundation
import SwiftData

@Model
final class Task {

    // MARK: - Properties

    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var priorityRaw: Int
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    /// Reminder: nil = none, 0 = at due time, >0 = minutes before due.
    var reminderMinutesBefore: Int?
    /// Optional tags (many-to-many; one-way relationship).
    @Relationship(deleteRule: .nullify)
    var tags: [Tag]?

    var category: Category?

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category? = nil,
        reminderMinutesBefore: Int? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.category = category
        self.reminderMinutesBefore = reminderMinutesBefore
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
    }

    // MARK: - Computed

    /// Whether the task is overdue (due date in the past and not completed).
    var isOverdue: Bool {
        guard !isCompleted, let due = dueDate else { return false }
        return due < Date()
    }

    /// Whether the task is due today (calendar day).
    var isDueToday: Bool {
        guard let due = dueDate else { return false }
        return Calendar.current.isDateInToday(due)
    }
}
