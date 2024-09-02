//
//  Sourdough_HelperApp.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 5/28/21.
//

import SwiftUI

@main
struct Sourdough_HelperApp: App {
    @State private var schedule: Schedule = Schedule()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(schedule)
        }
    }
}
