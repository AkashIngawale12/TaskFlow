//
//  NotificationService.swift
//  TaskFlow
//
//  Local notifications for task reminders; snooze (15 min, 1 hour, tomorrow).
//

import Foundation
import UserNotifications

enum NotificationService {

    // MARK: - Task Reminders (snooze)

    static let snooze15Identifier = "snooze15"
    static let snooze1HourIdentifier = "snooze1hour"
    static let snoozeTomorrowIdentifier = "snoozeTomorrow"

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Call from sync context (e.g. button) to request permission.
    static func requestAuthorizationInBackground() {
        _Concurrency.Task { _ = await requestAuthorization() }
    }

    // MARK: - Task Reminder Schedule / Snooze

    /// Schedule reminder for task. Pass nil to remove. Call after permission is granted.
    static func scheduleReminder(taskId: UUID, title: String, dueDate: Date, minutesBefore: Int?) {
        let center = UNUserNotificationCenter.current()
        let id = taskId.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard let minutes = minutesBefore, minutes >= 0 else { return }
        let fireDate = Calendar.current.date(byAdding: .minute, value: -minutes, to: dueDate)!
        if fireDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = "TaskFlow"
        content.body = title
        content.sound = .default
        content.userInfo = ["taskId": taskId.uuidString, "title": title]
        content.categoryIdentifier = "TASK_REMINDER"

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    /// Snooze: reschedule for 15 min, 1 hour, or tomorrow 9am.
    static func snooze(taskId: UUID, title: String, option: SnoozeOption) {
        let center = UNUserNotificationCenter.current()
        let oldId = taskId.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [oldId])

        let (snoozeDate, identifier): (Date, String) = {
            let cal = Calendar.current
            switch option {
            case .minutes15:
                return (cal.date(byAdding: .minute, value: 15, to: Date())!, Self.snooze15Identifier + "-" + oldId)
            case .hour1:
                return (cal.date(byAdding: .hour, value: 1, to: Date())!, Self.snooze1HourIdentifier + "-" + oldId)
            case .tomorrow:
                let tomorrow = cal.date(byAdding: .day, value: 1, to: Date())!
                let nineAM = cal.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
                return (nineAM, Self.snoozeTomorrowIdentifier + "-" + oldId)
            }
        }()

        let content = UNMutableNotificationContent()
        content.title = "TaskFlow (reminder)"
        content.body = title
        content.sound = .default
        content.userInfo = ["taskId": taskId.uuidString, "title": title]
        content.categoryIdentifier = "TASK_REMINDER"

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: snoozeDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Habit Reminders

    /// Identifier prefix for habit notifications (habitId + weekday).
    private static func habitNotificationIdentifier(habitId: UUID, weekday: Int) -> String {
        "habit-\(habitId.uuidString)-w\(weekday)"
    }

    /// Remove all pending notifications for a habit.
    static func removeReminderForHabit(habitId: UUID) {
        let center = UNUserNotificationCenter.current()
        let ids = (1...7).map { habitNotificationIdentifier(habitId: habitId, weekday: $0) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Schedule daily reminder for a habit at reminderTime on each repeat weekday. Pass nil reminderTime to remove.
    static func scheduleReminderForHabit(habitId: UUID, name: String, reminderTime: Date?, repeatWeekdays: [Int]) {
        removeReminderForHabit(habitId: habitId)
        guard let time = reminderTime else { return }
        let cal = Calendar.current
        let hour = cal.component(.hour, from: time)
        let minute = cal.component(.minute, from: time)
        let weekdays = repeatWeekdays.isEmpty ? Array(1...7) : repeatWeekdays
        let center = UNUserNotificationCenter.current()
        for weekday in weekdays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            components.second = 0
            let content = UNMutableNotificationContent()
            content.title = "TaskFlow"
            content.body = "Habit: \(name)"
            content.sound = .default
            content.userInfo = ["habitId": habitId.uuidString, "type": "habit"]
            content.categoryIdentifier = "HABIT_REMINDER"
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id = habitNotificationIdentifier(habitId: habitId, weekday: weekday)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Categories

    static func registerCategories() {
        let snooze15 = UNNotificationAction(identifier: Self.snooze15Identifier, title: "15 min", options: [])
        let snooze1h = UNNotificationAction(identifier: Self.snooze1HourIdentifier, title: "1 hour", options: [])
        let snoozeTomorrow = UNNotificationAction(identifier: Self.snoozeTomorrowIdentifier, title: "Tomorrow", options: [])
        let taskCategory = UNNotificationCategory(identifier: "TASK_REMINDER", actions: [snooze15, snooze1h, snoozeTomorrow], intentIdentifiers: [])
        let habitCategory = UNNotificationCategory(identifier: "HABIT_REMINDER", actions: [], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([taskCategory, habitCategory])
    }

    // MARK: - Types

    enum SnoozeOption {
        case minutes15, hour1, tomorrow
    }
}
