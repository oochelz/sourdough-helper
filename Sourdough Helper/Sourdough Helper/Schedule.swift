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

@Observable class Schedule: Codable {
    var tasks: [Task]
    var intervalInMin: Int = 0
    var bulkFermentationEndTime: Date? = nil

    private static let userDefaultsKey = "savedSchedule"

    public init() {
        self.tasks = []
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }

    static func load() -> Schedule? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
        else { return nil }
        return schedule
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case tasks, intervalInMin, bulkFermentationEndTime
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tasks = try container.decode([Task].self, forKey: .tasks)
        intervalInMin = try container.decode(Int.self, forKey: .intervalInMin)
        bulkFermentationEndTime = try container.decodeIfPresent(Date.self, forKey: .bulkFermentationEndTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(intervalInMin, forKey: .intervalInMin)
        try container.encodeIfPresent(bulkFermentationEndTime, forKey: .bulkFermentationEndTime)
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

        if let begin = tasks.first { completeTask(begin) }
        scheduleBulkFermentationNotification(after: bulkDurationSec)
        save()

        return self
    }

    public func completeTask(_ task: Task) -> Void {
        // Guard: only the next incomplete task may be completed
        guard let next = tasks.first(where: { !$0.isComplete }), next.id == task.id else { return }

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

        save()
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
