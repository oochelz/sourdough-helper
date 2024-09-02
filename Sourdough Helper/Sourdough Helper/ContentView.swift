//
//  ContentView.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 5/28/21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @Environment(Schedule.self) private var schedule
    
    var body: some View {
        NavigationView {
            if schedule.tasks.isEmpty {
                CreateScheduleView()
                    .environment(schedule)
                    .navigationTitle("Sourdough Helper")
            } else {
                ScheduleView()
                    .environment(schedule)
                    .navigationTitle("Sourdough Helper")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             ContentView().preferredColorScheme($0)
                .environment(Schedule())
        }
    }
}
