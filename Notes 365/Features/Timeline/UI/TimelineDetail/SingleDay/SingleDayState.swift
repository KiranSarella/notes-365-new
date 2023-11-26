//
//  SingleDayState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//
import SwiftUI

struct DayTimelineModel {
    let date: Date
    var timelines = [Timeline]()
    
    mutating func showTimelines(newValues: [Timeline]) {
        timelines = newValues
    }
}

@Observable
class SingleDayViewState {
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    var timelines = [Timeline]()
    var isLoaded = false
    
    init() { }
    
    func loadDay(_ date: Date) {
        logger.info("load day: \(date)")
        Task {
            do {
                await NotebooksPathService.shared.refreshNotebooksInfo()
                let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: date)
                self.timelines = results.map { $0.timeline }
                logger.info("\(date) - timelines count: \(self.timelines.count)")
//                try? await Task.sleep(nanoseconds: 3_000_000_000)
                isLoaded = true
            } catch let error {
                logger.error("\(error)")
                isLoaded = true
            }
        }
    }
    
    
}
