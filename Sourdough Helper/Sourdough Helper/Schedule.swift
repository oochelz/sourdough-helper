//
//  Schedule.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI

@Observable class Schedule {
    var tasks: [Task]
    var intervalInMin: Int = 0
    
    public init() {
        self.tasks = []
    }
    
    public func create(intervalInMin: Int, totalDurationInHr: Int) -> Schedule {
        self.intervalInMin = intervalInMin
        let numTasks = totalDurationInHr * 60 / intervalInMin
        tasks = []
        tasks.append(Task(name: "Begin", isComplete: false, startTime: Date.now))
        
        for index in 1...numTasks {
            tasks.append(Task(name: "Fold " + String(index)))
        }
        tasks.append(Task(name: "Done!", isComplete: true))
        
        completeTask()
        
        return self
    }
    
    public func completeTask() -> Void {
        // Complete the task
        // TODO: Make this modify the given task, instead of finding one in the list
        let task = tasks.first { t in
            t.isComplete == false
        }
        guard let task = task else { return }
        task.complete()
        
        queueNotification()
    }
    
    private func queueNotification() -> Void {
        let content = UNMutableNotificationContent()
        content.title = "Stretch the dough"
        content.body = "It's that time. Stretchy stretchy."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(intervalInMin * 60), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
