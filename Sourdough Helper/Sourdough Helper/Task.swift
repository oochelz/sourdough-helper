//
//  Task.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI
import UserNotifications

@Observable class Task: Identifiable {
    var name: String
    var isComplete: Bool = false
    var durationInMin: Int
    var startTime: Date? = nil
    
    public init(name: String, durationInMin: Int, isComplete: Bool = false) {
        self.name = name
        self.durationInMin = durationInMin
        self.isComplete = isComplete
    }
    
    public func start() -> Void {
        self.startTime = Date()
        
        let content = UNMutableNotificationContent()
        content.title = "Stretch the dough"
        content.body = "It's that time. Stretchy stretchy."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(self.durationInMin * 60), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    public func complete() -> Void {
        self.isComplete = true
    }
}
