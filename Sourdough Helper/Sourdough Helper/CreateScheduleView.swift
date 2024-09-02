//
//  CreateScheduleView.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI

struct CreateScheduleView: View {
    @State private var showingAlert = false
    @State private var intervalInMin = 30.0
    @State private var durationInHr = 4.0
    
    @Environment(Schedule.self) private var schedule

    fileprivate func createSchedule() {
        _ = schedule.create(intervalInMin: Int(intervalInMin), totalDurationInHr: Int(durationInHr))
    }
    
    var body: some View {
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
                Text("^[\(Int(durationInHr)) hours](inflect: true)")
                    .font(.subheadline)
            }
            Button("Create Schedule") {
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
                    createSchedule()
                }
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(
                    title: Text("Enable Notifications"),
                    message: Text("To get alerts, you need to enable notifications in Settings."),
                    dismissButton: .default(Text("Got it"))
                )
            })
        }
    }
}

#Preview {
    CreateScheduleView()
        .environment(Schedule())
}
