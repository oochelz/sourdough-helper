//
//  ContentView.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 5/28/21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var showingAlert = false
    
    fileprivate func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Stretch the dough"
        content.body = "It's that time. Stretchy stretchy."
        content.sound = UNNotificationSound.default
        let intervalInMin = 30
        let durationInHr = 4
        let intervalInSec = intervalInMin * 60
        let numNotifications = durationInHr * 60 / intervalInMin
        for index in 1...numNotifications {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(intervalInSec * index), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Start Timer") {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { success, error in }
                    
                    center.getNotificationSettings { settings in
                        guard (settings.authorizationStatus == .authorized) ||
                              (settings.authorizationStatus == .provisional) else {
                            showingAlert = true
                            return
                        }
                        scheduleNotifications()
                    }
                }
                .alert(isPresented: $showingAlert, content: {
                    Alert(
                        title: Text("Enable Notifications"),
                        message: Text("To get alerts, you need to enable notifications in Settings."),
                        dismissButton: .default(Text("Got it"))
                    )
                })
                .padding()
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.green)
            }
            .navigationTitle("Sourdough Helper")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
