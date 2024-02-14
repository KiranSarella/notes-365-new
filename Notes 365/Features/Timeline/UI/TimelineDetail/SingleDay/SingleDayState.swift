//
//  SingleDayState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//
import SwiftUI

struct DayTimelineModel: Identifiable {
    let id = UUID()
    let date: Date
    var timelines = [Timeline]()
    
    mutating func showTimelines(newValues: [Timeline]) {
        timelines = newValues
    }
}

struct DiscardTimelineInfo: Equatable {
//    let dayId: UUID
    let date: Date
    let fileId: UUID
    let changeId: String
}

@Observable
class SingleDayViewState {
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    var timelines = [Timeline]()
    var isLoaded = false
    
    init() { }
    
//    func loadDay(_ date: Date) {
//        logger.debug("load day: \(date)")
//        Task {
//            do {
////                await NotebooksPathService.shared.refreshNotebooksInfo()
//                let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: date)
//                for result in results {
//                    let r = await result.getTimeline()
//                    timelines.append(r)
//                }
//                isLoaded = true
//            } catch let error {
//                logger.error("\(error)")
//                isLoaded = true
//            }
//        }
//    }
    
    
}
