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
    var startTime: Date? = nil
    
    public init(name: String, isComplete: Bool = false, startTime: Date? = nil) {
        self.name = name
        self.isComplete = isComplete
        self.startTime = startTime
    }
    
    public func complete() -> Void {
        self.isComplete = true
        self.startTime = Date()
    }
}
