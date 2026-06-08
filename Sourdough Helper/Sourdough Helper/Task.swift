//
//  Task.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI
import UserNotifications

@Observable class Task: Identifiable, Codable {
    let id: UUID
    var name: String
    var isComplete: Bool = false
    var startTime: Date? = nil
    var pendingNotificationID: String? = nil

    public init(name: String, isComplete: Bool = false, startTime: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.isComplete = isComplete
        self.startTime = startTime
    }

    public func complete() -> Void {
        self.isComplete = true
        self.startTime = Date()
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, isComplete, startTime, pendingNotificationID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        pendingNotificationID = try container.decodeIfPresent(String.self, forKey: .pendingNotificationID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(pendingNotificationID, forKey: .pendingNotificationID)
    }
}
