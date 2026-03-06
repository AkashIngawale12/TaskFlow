//
//  TaskFlowTests.swift
//  TaskFlowTests
//
//  Unit tests for models and view model logic.
//

import XCTest
@testable import TaskFlow

final class TaskFlowTests: XCTestCase {

    // MARK: - Priority

    func testPriority_rawValues() {
        XCTAssertEqual(Priority.low.rawValue, 0)
        XCTAssertEqual(Priority.medium.rawValue, 1)
        XCTAssertEqual(Priority.high.rawValue, 2)
    }

    func testPriority_displayNames() {
        XCTAssertEqual(Priority.low.displayName, "Low")
        XCTAssertEqual(Priority.medium.displayName, "Medium")
        XCTAssertEqual(Priority.high.displayName, "High")
    }

    func testPriority_sortOrder() {
        XCTAssertEqual(Priority.low.sortOrder, 0)
        XCTAssertEqual(Priority.high.sortOrder, 2)
    }

    // MARK: - TaskFilter

    func testTaskFilter_allCases() {
        XCTAssertEqual(TaskFilter.allCases.map(\.rawValue), ["All", "Today", "Overdue", "Completed"])
    }

    func testTaskFilter_identifiable() {
        for f in TaskFilter.allCases {
            XCTAssertEqual(f.id, f.rawValue)
        }
    }
}
