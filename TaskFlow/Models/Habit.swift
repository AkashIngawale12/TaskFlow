//
//  Habit.swift
//  TaskFlow
//
//  SwiftData model for daily habits (e.g. Exercise, Read).
//

import Foundation
import SwiftData

@Model
final class Habit {

    // MARK: - Properties

    var id: UUID
    var name: String
    var createdAt: Date
    /// Weekdays when habit repeats (1 = Sunday … 7 = Saturday). Empty = every day.
    var repeatWeekdays: [Int]
    /// Daily reminder time (only hour/minute used). Nil = no reminder.
    var reminderTime: Date?

    @Relationship(deleteRule: .cascade, inverse: \HabitCheckIn.habit)
    var checkIns: [HabitCheckIn]?

    // MARK: - Init

    init(id: UUID = UUID(), name: String, repeatWeekdays: [Int] = [], reminderTime: Date? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.repeatWeekdays = repeatWeekdays
        self.reminderTime = reminderTime
        self.createdAt = createdAt
    }

    // MARK: - Schedule

    /// True if habit is scheduled on the given weekday (1 = Sunday … 7 = Saturday).
    func isScheduled(on weekday: Int) -> Bool {
        guard (1...7).contains(weekday) else { return false }
        if repeatWeekdays.isEmpty { return true }
        return repeatWeekdays.contains(weekday)
    }

    /// True if habit is scheduled on today’s weekday.
    var isScheduledToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return isScheduled(on: weekday)
    }
}

extension Habit: Identifiable {}

// MARK: - Check-in (one per calendar day per habit)

@Model
final class HabitCheckIn {
    var id: UUID
    var date: Date // start of calendar day
    var habit: Habit?

    init(id: UUID = UUID(), date: Date, habit: Habit? = nil) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.habit = habit
    }
}

extension HabitCheckIn: Identifiable {}
