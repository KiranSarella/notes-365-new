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
    var remainingDaysToLoad = [Date]()
    var dayTimelineModels = [Timeline]()
    var currentLoadingDate = DateTime.now()
    var currentDayModel = DayTimelineModel(date: DateTime.now())
    var currentDateLoadingState = CurrentDateLoadingState(date: DateTime.now(), timmelinesCount: 0)
    var canLoadMore = true
    var statusMessage: String?
//    var currentDayLoaded = false
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    
    var initialLoadDone = false
    var scrolledID: Timeline.ID?
//    var scrolledTimelineID: Timeline.ID?
    var contentLength: Int = 0
    
    var blockOtherRequests = false
    
    func startloading(days: [Date]) {
        logger.info("startLoadingDays - \(days)")
        resetFields()
        remainingDaysToLoad = days
        tryLoadNextDay()
    }
    
    func resetFields() {
        dayTimelineModels.removeAll()
        currentLoadingDate = DateTime.now()
        canLoadMore = true
        statusMessage = "Loading.."
        contentLength = 0
        initialLoadDone = false
    }
    
    var isContentFilledToScrollable: Bool {
        logger.debug("contentLength: \(self.contentLength)")
        return contentLength > 10000
    }

    
    var anyDaysAvailable: Bool {
        if remainingDaysToLoad.count == 0 {
            canLoadMore = false
            logger.debug("all loaded.")
            if dayTimelineModels.isEmpty {
                statusMessage = "Empty"
                logger.debug("no content")
            } else {
                statusMessage = nil
            }
            return false
        }
        return true
    }
    
//    var isLastDayAllDisplayed: Bool {
//        guard let lastTimelines = dayTimelineModels.last?.timelines else { return true }
//        let pendingCound = lastTimelines.reduce(0, { partialResult, tl in
//            if tl.canDisplayContent == false {
//                return 1
//            } else {
//                return 0
//            }
//        })
//        
//        if pendingCound == 0 {
//            return true
//        } else {
//            return false
//        }
//    }
    
    
    func loadContent(_ timeline: inout Timeline) async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
//        timeline.canDisplayContent = true
//
//        DispatchQueue.main.async {
//            timeline.canDisplayContent = true
//            logger.debug("canDisplayContent")
//            self.isContentLoading = false
//        }
    }
    
    func loadNext() {
        if blockOtherRequests { return }
        logger.debug("\(#function)")
//        if isContentLoading { return }
        if currentDayModel.timelines.isEmpty == false {
            Task {
                blockOtherRequests = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let timeline =  currentDayModel.timelines.removeFirst()
                dayTimelineModels.append(timeline)
                blockOtherRequests = false
            }
        } else {
            tryLoadNextDay()
        }
    }
    
    func tryLoadNextDay() {
        logger.debug("\(#function)")
        
        if canLoadMore == false { return }
        // enable waiting flag and do once all displayed.
//        if isLastDayAllDisplayed == false { return }
        
        if anyDaysAvailable {
            loadNextDay()
        }
    }
    
    
    private func loadNextDay() {
        logger.debug("\(#function)")
        
        // delay some time, to load next day
        
        
        currentLoadingDate = remainingDaysToLoad.removeFirst()
//        currentDayLoaded = false
        Task {
            let dayTimelines = await prepareTimelines(for: currentLoadingDate)
            logger.debug("timelines for date: \(dayTimelines.count)")
            if dayTimelines.count > 0 {
                blockOtherRequests = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let newDayRow = DayTimelineModel(date: currentLoadingDate, timelines: dayTimelines)
//                newDayRow.timelines.first?.setAsFirst()
                currentDayModel = newDayRow
                var timeline =  currentDayModel.timelines.removeFirst()
                timeline.setAsFirst()
                dayTimelineModels.append(timeline)
                blockOtherRequests = false
                await loadNextDaysTillScreenFills(newDayRow)
            } else {
                // auto try next day
//                try? await Task.sleep(nanoseconds: 1_000_000_000)
                tryLoadNextDay()
            }
        }
    }
    
    fileprivate func loadNextDaysTillScreenFills(_ newDayRow: DayTimelineModel) async {
        if initialLoadDone == false {
            logger.debug("\(#function)")
            for timeline in newDayRow.timelines {
                contentLength += timeline.content?.count ?? 0
            }
            if isContentFilledToScrollable == false {
                logger.debug("isContentFilledToScrollable")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                tryLoadNextDay()
            } else {
                initialLoadDone = true
            }
        }
    }
    
    
    var displayingCount = 0
    
//    func displayOneByOne() {
//        logger.debug("\(#function)")
//        if displayingCount >= dayTimelines.timelines.count { return }
//        
//        DispatchQueue.main.async {
//            dayTimelines.timelines[displayingCount].canDisplayContent = true
//        }
//        Task {
//            try? await Task.sleep(nanoseconds: 2_000_000_000)
//            displayingCount += 1
//            displayOneByOne()
//        }
//    }
    
    
    func prepareTimelines(for date: Date) async -> [Timeline] {
        logger.debug("load day: \(date)")
        var timelines = [Timeline]()
        do {
//            await NotebooksPathService.shared.refreshNotebooksInfo()
            let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: date)
            for result in results {
                let r = await result.getTimeline(date: date)
                timelines.append(r)
            }
        } catch let error {
            logger.error("\(error)")
        }
        return timelines
    }
 
    func discardTimelineChanges(info: DiscardTimelineInfo) {
//        logger.info("\(#function)")
//        do {
////            try timelineBusiness.discard(changeId: info.changeId, date: info.date, fileId: info.fileId)
//            // remove from UI
//            if let index = dayTimelineModels.firstIndex(where: { $0.id == info.dayId }) {
//                if dayTimelineModels[index].timelines.count > 1 {
//                    // remove timeline inside a day
//                    dayTimelineModels[index].timelines.removeAll { t in
//                        t.fileUUID == info.fileId
//                    }
//                } else {
//                    // remove day itself
//                    dayTimelineModels.remove(at: index)
//                }
//            }
//        } catch let error {
//            logger.error("\(error)")
//        }
    }
    
}
