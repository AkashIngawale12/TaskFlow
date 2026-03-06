//
//  TaskEditViewModel.swift
//  TaskFlow
//
//  MVVM: Handles add/edit task form state and persistence.
//

import Foundation
import SwiftData

/// Reminder: nil = none, 0 = at due time, else minutes before due.
enum ReminderOption: Int, CaseIterable, Identifiable {

    // MARK: - Cases

    case none = -1
    case atDueTime = 0
    case minutes5 = 5
    case minutes15 = 15
    case minutes30 = 30
    case hour1 = 60
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .none: return "None"
        case .atDueTime: return "At due time"
        case .minutes5: return "5 min before"
        case .minutes15: return "15 min before"
        case .minutes30: return "30 min before"
        case .hour1: return "1 hour before"
        }
    }
}

@MainActor
final class TaskEditViewModel: ObservableObject {

    // MARK: - Published

    @Published var title: String = ""
    @Published var notes: String = ""
    @Published var dueDate: Date = Date()
    @Published var hasDueDate: Bool = false
    @Published var priority: Priority = .medium
    @Published var category: Category?
    @Published var reminderOption: ReminderOption = .none
    @Published var selectedTags: [Tag] = []

    private var task: Task?
    private var modelContext: ModelContext?

    var isEditing: Bool { task != nil }

    // MARK: - Init

    init(task: Task? = nil, modelContext: ModelContext? = nil) {
        self.task = task
        self.modelContext = modelContext
        if let t = task {
            title = t.title
            notes = t.notes
            dueDate = t.dueDate ?? Date()
            hasDueDate = t.dueDate != nil
            priority = t.priority
            category = t.category
            if let min = t.reminderMinutesBefore {
                reminderOption = ReminderOption(rawValue: min) ?? .none
            } else {
                reminderOption = .none
            }
            selectedTags = t.tags ?? []
        }
    }

    // MARK: - Public Methods

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func save() throws {
        guard let context = modelContext else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let finalDue = hasDueDate ? dueDate : nil
        let reminderMinutes: Int? = (reminderOption == .none || !hasDueDate) ? nil : (reminderOption.rawValue >= 0 ? reminderOption.rawValue : nil)

        if let existing = task {
            existing.title = trimmed
            existing.notes = notes
            existing.dueDate = finalDue
            existing.priority = priority
            existing.category = category
            existing.reminderMinutesBefore = reminderMinutes
            existing.tags = selectedTags.isEmpty ? nil : selectedTags
            if let due = finalDue, let min = reminderMinutes, min >= 0 {
                NotificationService.scheduleReminder(taskId: existing.id, title: trimmed, dueDate: due, minutesBefore: min)
            } else {
                NotificationService.scheduleReminder(taskId: existing.id, title: trimmed, dueDate: Date(), minutesBefore: nil)
            }
        } else {
            let newTask = Task(
                title: trimmed,
                notes: notes,
                dueDate: finalDue,
                priority: priority,
                category: category,
                reminderMinutesBefore: reminderMinutes
            )
            if !selectedTags.isEmpty { newTask.tags = selectedTags }
            context.insert(newTask)
            if let due = finalDue, let min = reminderMinutes, min >= 0 {
                NotificationService.scheduleReminder(taskId: newTask.id, title: trimmed, dueDate: due, minutesBefore: min)
            }
        }
        try context.save()
    }

    func deleteTask() throws {
        guard let context = modelContext, let t = task else { return }
        context.delete(t)
        try context.save()
    }
}
