//
//  TaskModelTests.swift
//  TaskFlowTests
//
//  Tests for Task model computed properties (isOverdue, isDueToday)
//  using in-memory SwiftData container.
//

import XCTest
import SwiftData
@testable import TaskFlow

@MainActor
final class TaskModelTests: XCTestCase {

    func testTask_isOverdue_whenPastDueAndNotCompleted() throws {
        let container = try ModelContainer(for: Task.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let task = Task(title: "Overdue", dueDate: yesterday, isCompleted: false)
        context.insert(task)
        XCTAssertTrue(task.isOverdue)
    }

    func testTask_isOverdue_whenCompleted_returnsFalse() throws {
        let container = try ModelContainer(for: Task.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let task = Task(title: "Done", dueDate: yesterday, isCompleted: true, completedAt: Date())
        context.insert(task)
        XCTAssertFalse(task.isOverdue)
    }

    func testTask_isDueToday() throws {
        let container = try ModelContainer(for: Task.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let task = Task(title: "Today", dueDate: Date(), isCompleted: false)
        context.insert(task)
        XCTAssertTrue(task.isDueToday)
    }
}
