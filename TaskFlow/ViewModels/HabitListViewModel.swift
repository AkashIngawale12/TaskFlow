//
//  HabitListViewModel.swift
//  TaskFlow
//
//  Add/delete habits; toggle check-in for today.
//

import Foundation
import SwiftData

@MainActor
final class HabitListViewModel: ObservableObject {

    // MARK: - Private

    private var modelContext: ModelContext?

    // MARK: - Public Methods

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func addHabit(name: String, repeatWeekdays: [Int] = [], reminderTime: Date? = nil) throws {
        guard let context = modelContext else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let habit = Habit(name: trimmed, repeatWeekdays: repeatWeekdays, reminderTime: reminderTime)
        context.insert(habit)
        try context.save()
        NotificationService.scheduleReminderForHabit(habitId: habit.id, name: habit.name, reminderTime: habit.reminderTime, repeatWeekdays: habit.repeatWeekdays)
    }

    func updateHabit(_ habit: Habit, name: String, repeatWeekdays: [Int], reminderTime: Date? = nil) throws {
        guard let context = modelContext else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        habit.name = trimmed
        habit.repeatWeekdays = repeatWeekdays
        habit.reminderTime = reminderTime
        try context.save()
        NotificationService.scheduleReminderForHabit(habitId: habit.id, name: habit.name, reminderTime: habit.reminderTime, repeatWeekdays: habit.repeatWeekdays)
    }

    func deleteHabit(_ habit: Habit) throws {
        guard let context = modelContext else { return }
        NotificationService.removeReminderForHabit(habitId: habit.id)
        context.delete(habit)
        try context.save()
    }

    func toggleCheckIn(for habit: Habit) throws {
        guard let context = modelContext else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let checkIns = habit.checkIns ?? []
        if let existing = checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            context.delete(existing)
        } else {
            let checkIn = HabitCheckIn(date: today, habit: habit)
            context.insert(checkIn)
        }
        try context.save()
    }
}
