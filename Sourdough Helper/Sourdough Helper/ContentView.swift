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
    @State private var showingSuccess = false
    @State private var intervalInMin = 5.0
    @State private var durationInHr = 1.0
    
    fileprivate func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Stretch the dough"
        content.body = "It's that time. Stretchy stretchy."
        content.sound = UNNotificationSound.default
        let intervalInSec = Int(intervalInMin) * 60
        let numNotifications = Int(durationInHr) * 60 / Int(intervalInMin)
        for index in 1...numNotifications {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(intervalInSec * index), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        showingSuccess = true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("How often do you need to fold?")
                    HStack {
                        Image(systemName: "minus")
                        Slider(value: $intervalInMin, in: 5...60, step: 5)
                        Image(systemName: "plus")
                    }
                    Text("Every \(Int(intervalInMin)) minutes")
                        .font(.subheadline)
                }
                Section {
                    Text("For how long?")
                    HStack {
                        Image(systemName: "minus")
                        Slider(value: $durationInHr, in: 1...12, step: 1)
                        Image(systemName: "plus")
                    }
                    Text("\(Int(durationInHr)) hours")
                        .font(.subheadline)
                }
                Button("Start Timer") {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if error != nil {
                            showingAlert = true
                            return
                        }
                    }
                    
                    center.getNotificationSettings { settings in
                        guard (settings.authorizationStatus == .authorized) else {
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
                .alert(isPresented: $showingSuccess, content: {
                    Alert(
                        title: Text("Timers Set"),
                        message: Text("You'll get alerts to stretch your dough."),
                        dismissButton: .default(Text("OK"))
                    )
                })
            }
            .navigationTitle("Sourdough Helper")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             ContentView().preferredColorScheme($0)
        }
    }
}
