//
//  ScheduleView.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI

struct ScheduleView: View {
    @Environment(Schedule.self) private var schedule

    var body: some View {
        List(schedule.tasks) { task in
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Button("", systemImage: task.isComplete ? "checkmark.circle.fill" : "circle") {
                        schedule.completeTask()
                    }
                    .disabled(task.isComplete)
                    VStack(alignment: .leading)  {
                        Text(task.name)
                        if (!task.isComplete && (task.startTime) != nil) {
                            Text("Started \(DateFormatter.localizedString(from: task.startTime!, dateStyle: .short, timeStyle: .short))")
                                .font(.footnote)
                                .foregroundColor(Color("Mustard"))
                        }
                    }
                }
                if (task.durationInMin > 0) {
                    HStack {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color("Pistachio"))
                            .font(.title)
                            .padding(.trailing, 12)
                        Text("^[\(task.durationInMin) minutes](inflect:true)")
                            .font(.footnote)
                            .foregroundColor(Color("Pistachio"))
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    ScheduleView()
        .environment(Schedule().create(intervalInMin: 5, totalDurationInHr: 3))
}
