//
//  HabitStreak.swift
//  TaskFlow
//
//  Computed streak from habit check-ins (consecutive days).
//

import Foundation
import SwiftData

enum HabitStreak {

    // MARK: - Streak

    /// Count consecutive days with check-ins ending at `upToDate` (typically today or yesterday).
    static func streak(for habit: Habit, upToDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: upToDate)
        guard let checkIns = habit.checkIns, !checkIns.isEmpty else { return 0 }

        let sortedDates = checkIns
            .compactMap { $0.date }
            .map { calendar.startOfDay(for: $0) }
            .reduce(into: Set<Date>()) { $0.insert($1) }
            .sorted(by: >)

        guard let mostRecent = sortedDates.first else { return 0 }
        // If most recent is before yesterday, streak is 0 (user missed a day).
        let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        if mostRecent < yesterday {
            return 0
        }

        var count = 0
        var current = startOfToday
        let startOfEarliest = sortedDates.last!

        while current >= startOfEarliest {
            if sortedDates.contains(where: { calendar.isDate($0, inSameDayAs: current) }) {
                count += 1
                current = calendar.date(byAdding: .day, value: -1, to: current)!
            } else {
                break
            }
        }
        return count
    }

    // MARK: - Today

    /// Whether the habit has been checked in today.
    static func isDoneToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return habit.checkIns?.contains { calendar.isDate($0.date, inSameDayAs: today) } ?? false
    }
}
