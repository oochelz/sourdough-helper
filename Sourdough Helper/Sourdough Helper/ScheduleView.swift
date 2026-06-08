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
        List {
            if let endTime = schedule.bulkFermentationEndTime {
                Section {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        BulkFermentationCountdown(endTime: endTime, now: context.date)
                    }
                }
            }

            ForEach(schedule.tasks) { task in
                VStack(alignment: .leading) {
                    HStack {
                        Button("", systemImage: task.isComplete ? "checkmark.circle.fill" : "circle") {
                            schedule.completeTask()
                        }
                        .disabled(task.isComplete)
                        Text(task.name)
                            .font(.title3)
                    }

                    let taskIndex = schedule.tasks.firstIndex(where: { $0.id == task.id })
                let isLastOrSecondToLast = taskIndex.map { $0 >= schedule.tasks.count - 2 } ?? true
                let nextTaskIsComplete = taskIndex.map { i -> Bool in
                    let nextIndex = i + 1
                    return nextIndex < schedule.tasks.count ? schedule.tasks[nextIndex].isComplete : true
                } ?? true
                if !isLastOrSecondToLast && !nextTaskIsComplete {
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
    }

    private func timerText(startTime: Date) -> some View {
        let end = startTime.advanced(by: TimeInterval(schedule.intervalInMin * 60))
        let formattedTime = DateFormatter.localizedString(from: end, dateStyle: .none, timeStyle: .short)

        return Text("(at \(formattedTime))")
            .font(.footnote)
            .foregroundColor(Color("Mustard"))
    }
}

struct BulkFermentationCountdown: View {
    let endTime: Date
    let now: Date

    var body: some View {
        let remaining = endTime.timeIntervalSince(now)
        let isComplete = remaining <= 0

        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "timer")
                .foregroundColor(isComplete ? Color("Pistachio") : Color("Mustard"))
            VStack(alignment: .leading) {
                Text("Bulk Fermentation")
                    .font(.headline)
                if isComplete {
                    Text("Complete")
                        .font(.subheadline)
                        .foregroundColor(Color("Pistachio"))
                } else {
                    Text(timeString(from: remaining))
                        .font(.subheadline)
                        .foregroundColor(Color("Mustard"))
                    Text("ends at \(DateFormatter.localizedString(from: endTime, dateStyle: .none, timeStyle: .short))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d remaining", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d remaining", minutes, seconds)
        }
    }
}

#Preview {
    ScheduleView()
        .environment(Schedule().create(intervalInMin: 20, numFolds: 3, bulkFermentationInHr: 2))
}
