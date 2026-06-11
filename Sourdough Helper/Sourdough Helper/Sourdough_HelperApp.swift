//
//  Sourdough_HelperApp.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 5/28/21.
//

import SwiftUI
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
        if response.actionIdentifier == UNNotificationAction.markCompleteIdentifier,
           let next = schedule.tasks.first(where: { !$0.isComplete }) {
            schedule.completeTask(next)
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

@main
struct Sourdough_HelperApp: App {
    @State private var schedule: Schedule = Schedule()
    private let notificationDelegate: NotificationDelegate

    init() {
        let schedule = Schedule.load() ?? Schedule()
        self.notificationDelegate = NotificationDelegate(schedule: schedule)
        self._schedule = State(initialValue: schedule)

        registerNotificationCategories()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(schedule)
        }
    }
}
