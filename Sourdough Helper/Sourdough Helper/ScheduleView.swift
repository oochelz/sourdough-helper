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
                HStack {
                    Button("", systemImage: task.isComplete ? "checkmark.circle.fill" : "circle") {
                        schedule.completeTask()
                    }
                    .disabled(task.isComplete)
                    Text(task.name)
                        .font(.title3)
                }
                
                if (schedule.tasks.last?.id != task.id) {
                    HStack {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color("Pistachio"))
                            .font(.title)
                            .padding(.trailing, 12)
                        HStack {
                            Text("Wait ^[\(schedule.intervalInMin) minutes](inflect:true)")
                                .font(.footnote)
                                .foregroundColor(Color("Pistachio"))
                            if (task.startTime != nil) {
                                timerText(startTime: task.startTime!)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                }
            }
            .listRowSeparator(.hidden)
        }
    }
    
    private func timerText(startTime: Date) -> some View {
        let end = startTime.advanced(by: TimeInterval(schedule.intervalInMin * 60))
        let formattedTime = DateFormatter.localizedString(from: end, dateStyle: .none, timeStyle: .short)
        
        return Text("(at \(formattedTime))")
            .font(.footnote)
            .foregroundColor(Color("Mustard"))
    }
}

#Preview {
    ScheduleView()
        .environment(Schedule().create(intervalInMin: 20, totalDurationInHr: 1))
}
