//
//  Schedule.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI
import UserNotifications

extension UNNotificationCategory {
    static let foldCategoryIdentifier = "FOLD_REMINDER"
}

extension UNNotificationAction {
    static let markCompleteIdentifier = "MARK_FOLD_COMPLETE"
}

func registerNotificationCategories() {
    let markCompleteAction = UNNotificationAction(
        identifier: UNNotificationAction.markCompleteIdentifier,
        title: "Mark Complete",
        options: []
    )
    let foldCategory = UNNotificationCategory(
        identifier: UNNotificationCategory.foldCategoryIdentifier,
        actions: [markCompleteAction],
        intentIdentifiers: [],
        options: []
    )
    UNUserNotificationCenter.current().setNotificationCategories([foldCategory])
}

@Observable class Schedule {
    var tasks: [Task]
    var intervalInMin: Int = 0
    var bulkFermentationEndTime: Date? = nil

    public init() {
        self.tasks = []
    }

    public func create(intervalInMin: Int, numFolds: Int, bulkFermentationInHr: Int) -> Schedule {
        self.intervalInMin = intervalInMin
        let bulkDurationSec = Double(bulkFermentationInHr * 3600)
        bulkFermentationEndTime = Date.now.addingTimeInterval(bulkDurationSec)

        // Cap folds so they don't extend past bulk fermentation end
        let maxFolds = bulkFermentationInHr * 60 / intervalInMin
        let effectiveFolds = min(numFolds, maxFolds)

        tasks = []
        tasks.append(Task(name: "Begin", isComplete: false, startTime: Date.now))
        for index in 1...max(1, effectiveFolds) {
            tasks.append(Task(name: "Fold " + String(index)))
        }
        tasks.append(Task(name: "Done!"))

        completeTask()
        scheduleBulkFermentationNotification(after: bulkDurationSec)

        return self
    }

    public func completeTask() -> Void {
        // TODO: Make this modify the given task, instead of finding one in the list
        let task = tasks.first { t in
            t.isComplete == false
        }
        guard let task = task else { return }

        // Cancel any pending notification for this task (fired early by manual tap)
        if let notificationID = task.pendingNotificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        }

        task.complete()

        // If the only remaining task is "Done!", complete it automatically
        let nextIncomplete = tasks.first { !$0.isComplete }
        if let next = nextIncomplete, next.id == tasks.last?.id {
            next.complete()
        } else if let next = nextIncomplete {
            next.pendingNotificationID = queueFoldNotification()
        }
    }

    @discardableResult
    private func queueFoldNotification() -> String {
        let content = UNMutableNotificationContent()
        content.title = "Stretch the dough"
        content.body = "It's time to stretchy stretchy."
        content.sound = UNNotificationSound.default

        content.categoryIdentifier = UNNotificationCategory.foldCategoryIdentifier

        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(intervalInMin * 60), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        return identifier
    }

    private func scheduleBulkFermentationNotification(after seconds: Double) -> Void {
        let content = UNMutableNotificationContent()
        content.title = "Bulk fermentation complete"
        content.body = "Time to shape your dough."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "bulk-fermentation-end", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
