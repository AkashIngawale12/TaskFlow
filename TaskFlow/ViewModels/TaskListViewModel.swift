//
//  TaskListViewModel.swift
//  TaskFlow
//
//  MVVM: Fetches and filters tasks from SwiftData; drives the home list UI.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {

    // MARK: - Published

    @Published var filter: TaskFilter = .all
    @Published var selectedCategoryId: UUID?

    private var modelContext: ModelContext?

    // MARK: - Public Methods

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Filtering

    /// Predicate for initial fetch (only completed vs not, to avoid date capture issues in #Predicate).
    func predicateForFetch() -> Predicate<Task>? {
        switch filter {
        case .all, .today, .overdue:
            return nil
        case .completed:
            return #Predicate<Task> { task in task.isCompleted }
        }
    }

    /// Apply Today/Overdue/All/Completed filter in memory using current date.
    func applyFilterToTasks(_ tasks: [Task]) -> [Task] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        switch filter {
        case .all:
            return tasks
        case .today:
            return tasks.filter { task in
                !task.isCompleted && task.dueDate != nil && calendar.isDateInToday(task.dueDate!)
            }
        case .overdue:
            return tasks.filter { task in
                !task.isCompleted && task.dueDate != nil && task.dueDate! < startOfToday
            }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }
}
