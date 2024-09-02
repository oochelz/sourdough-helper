//
//  Schedule.swift
//  Sourdough Helper
//
//  Created by Chelsea Youmans on 9/2/24.
//

import SwiftUI

@Observable class Schedule {
    var tasks: [Task]
    
    public init() {
        self.tasks = []
    }
    
    public func create(intervalInMin: Int, totalDurationInHr: Int) -> Schedule {
        let numTasks = totalDurationInHr * 60 / intervalInMin
        self.tasks = []
        for index in 1...numTasks {
            self.tasks.append(Task(name: "Fold " + String(index), durationInMin: intervalInMin))
        }
        self.tasks.append(Task(name: "Done!", durationInMin: 0, isComplete: true))
        return self
    }
    
    public func completeTask() -> Void {
        // Complete the task
        // TODO: Make this modify the given task, instead of finding one in the list
        let task = self.tasks.first { t in
            t.isComplete == false
        }
        guard let task = task else { return }
        task.complete()
        
        // Start the next one
        let nextTask = self.tasks.first { t in
            t.isComplete == false
        }
        guard let nextTask = nextTask else { return }
        nextTask.start()
    }
}
