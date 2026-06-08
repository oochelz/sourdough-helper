//
//  NotificationDelegate.swift
//  Sourdough Helper
//

import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let schedule: Schedule

    init(schedule: Schedule) {
        self.schedule = schedule
    }

    // Handle action responses (e.g. "Mark Complete" from a fold notification)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == UNNotificationAction.markCompleteIdentifier {
            schedule.completeTask()
        }
        completionHandler()
    }

    // Show notifications as banners even when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
