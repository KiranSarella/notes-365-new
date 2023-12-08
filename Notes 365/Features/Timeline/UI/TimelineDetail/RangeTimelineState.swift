//
//  RangeTimelineState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI



struct CurrentDateLoadingState {
    let date: Date
    let timmelinesCount: Int
}

extension CurrentDateLoadingState: Equatable {
    
}

@Observable
class RangeTimelineState {
    var givenDays = [Date]()
    var dayTimelineModels = [DayTimelineModel]()
    var currentLoadingDate = DateTime.now()
    var currentDateLoadingState = CurrentDateLoadingState(date: DateTime.now(), timmelinesCount: 0)
//    var daysContentExists:Set<Bool> = []
    var canLoadMore = false
    var statusMessage: String?
    var atleastOneDayExists = false
    var currentDayLoaded = false
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    
    func startloading(days: [Date]) {
        logger.info("startLoadingDays - \(days)")
        resetFields()
        givenDays = days
        loadNextDay()
    }
    
    func resetFields() {
        dayTimelineModels.removeAll()
        currentLoadingDate = DateTime.now()
//        daysContentExists = []
        canLoadMore = false
        atleastOneDayExists = false
        statusMessage = "Loading.."
    }
    
//    func loadNextDay() {
//        logger.info("loadNextDay")
//        if givenDays.count == 0 {
//            canLoadMore = false
//            logger.info("all loaded.")
//            if !daysContentExists.contains(true) {
//                statusMessage = "No Content"
//                logger.info("no content")
//            }
//        } else {
//            currentLoadingDate = givenDays.removeFirst()
//            currentDayLoaded = false
//            showingDays.append(currentLoadingDate)
//        }
//    }
    
    func tryLoadMore() {
        logger.debug("tryLoadMore - currentDayLoaded: \(self.currentDayLoaded)")
        // have to maintain queue? - what if day content is single line?
        if currentDayLoaded == false {
            return
        }
        loadNextDay()
    }
    
    func loadNextDay() {
        logger.debug("loadNextDay")
        if givenDays.count == 0 {
            canLoadMore = false
            logger.debug("all loaded.")
            if dayTimelineModels.isEmpty {
                statusMessage = "Empty"
                logger.debug("no content")
            } else {
                statusMessage = nil
            }
        } else {
            currentLoadingDate = givenDays.removeFirst()
            currentDayLoaded = false
            Task {
                let timelines = await prepareTimelines(for: currentLoadingDate)
                logger.debug("timelines for date: \(self.currentDayLoaded) \(timelines.count)")
                if timelines.count > 0 {
                    let newDayRow = DayTimelineModel(date: currentLoadingDate, timelines: timelines)
                    dayTimelineModels.append(newDayRow)
                }
                loadNextDay()
            }
        }
    }
    
    func prepareTimelines(for date: Date) async -> [Timeline] {
        logger.debug("load day: \(date)")
        var timelines = [Timeline]()
        do {
            await NotebooksPathService.shared.refreshNotebooksInfo()
            let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: date)
            for result in results {
                let r = await result.getTimeline()
                timelines.append(r)
            }
        } catch let error {
            logger.error("\(error)")
        }
        return timelines
    }
 
    func discardTimelineChanges(info: DiscardTimelineInfo) {
        logger.info("\(#function)")
        // do business
        
        do {
            try timelineBusiness.discard(changeId: info.changeId, date: info.date, fileId: info.fileId)
            
            // remove from UI
            if let index = dayTimelineModels.firstIndex(where: { $0.id == info.dayId }) {
                if dayTimelineModels[index].timelines.count > 1 {
                    // remove timeline inside a day
                    dayTimelineModels[index].timelines.removeAll { t in
                        t.fileUUID == info.fileId
                    }
                } else {
                    // remove day itself
                    dayTimelineModels.remove(at: index)
                }
            }
        } catch let error {
            logger.error("\(error)")
        }
        
        
        
        
    }
    
}
