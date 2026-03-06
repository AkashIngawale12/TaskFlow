//
//  NotificationDelegate.swift
//  TaskFlow
//
//  Handles notification actions (snooze 15 min, 1 hour, tomorrow).
//

import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    // MARK: - Foreground Presentation

    /// Show banner and play sound when notification arrives while app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Action Handling

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let taskIdStr = userInfo["taskId"] as? String,
              let taskId = UUID(uuidString: taskIdStr),
              let title = userInfo["title"] as? String else {
            completionHandler()
            return
        }
        let actionId = response.actionIdentifier
        if actionId == NotificationService.snooze15Identifier {
            NotificationService.snooze(taskId: taskId, title: title, option: .minutes15)
        } else if actionId == NotificationService.snooze1HourIdentifier {
            NotificationService.snooze(taskId: taskId, title: title, option: .hour1)
        } else if actionId == NotificationService.snoozeTomorrowIdentifier {
            NotificationService.snooze(taskId: taskId, title: title, option: .tomorrow)
        }
        completionHandler()
    }
}
