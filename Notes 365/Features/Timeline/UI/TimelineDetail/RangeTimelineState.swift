//
//  RangeTimelineState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

//struct CurrentDateLoadingState {
//    let date: Date
//    let timmelinesCount: Int
//}
//
//extension CurrentDateLoadingState: Equatable {
//
//}

enum LoadingState {
    case notStarted
    case loading
    case empty
    case done
    
    var displayMessage: String? {
        switch self {
        case .notStarted:
            nil
        case .loading:
            "Loading.."
        case .empty:
            "Empty"
        case .done:
            nil
        }
    }
    
}

@Observable
class RangeTimelineState {
    var remainingDaysToLoad = [Date]()
    var dayTimelineModels = [Timeline]()
    var currentLoadingDate = DateTime.now()
    var currentDayModel = DayTimelineModel(date: DateTime.now())
    //    var currentDateLoadingState = CurrentDateLoadingState(date: DateTime.now(), timmelinesCount: 0)
    var loadingState: LoadingState = .notStarted
    //    var currentDayLoaded = false
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    
    var initialLoadDone = false
    var scrolledID: Timeline.ID?
    //    var scrolledTimelineID: Timeline.ID?
    var displayedContentLength: Int = 0
    
    let initialLoadCount: Int = 10000 // safe side keeping more.
    // better to get accurate value based on theme font size
    
    var blockOtherRequests = false
    
    func startloading(days: [Date]) {
        logger.info("startLoadingDays - \(days)")
        resetFields()
        remainingDaysToLoad = days
        loadNext()
    }
    
    func resetFields() {
        loadNextTask?.cancel()
        fetchNextDayTask?.cancel()
        dayTimelineModels.removeAll()
        remainingDaysToLoad.removeAll()
        scrolledID = nil
        blockOtherRequests = false
        currentLoadingDate = DateTime.now()
        currentDayModel = DayTimelineModel(date: DateTime.now())
        
        loadingState = .loading
        displayedContentLength = 0
        initialLoadDone = false
    }
    
    var isContentFilledToScrollable: Bool {
        logger.debug("contentLength: \(self.displayedContentLength)")
        return displayedContentLength > 10000
    }
    
    
    func updateStatusMessage() {
        if dayTimelineModels.isEmpty {
            loadingState = .empty
            logger.debug("no content.")
        } else {
            loadingState = .done
            logger.debug("all loaded.")
        }
    }
    
    //    var anyDaysAvailable: Bool {
    //        if remainingDaysToLoad.count == 0 {
    //            canLoadMore = false
    //            logger.debug("all loaded.")
    //            if dayTimelineModels.isEmpty {
    //                statusMessage = "Empty"
    //                logger.debug("no content")
    //            } else {
    //                statusMessage = nil
    //            }
    //            return false
    //        }
    //        return true
    //    }
    
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
    
    var loadNextTask: Task<(), Never>?
    var fetchNextDayTask: Task<(), Never>?
    
    func loadNext(_ delay: Bool = true) {
        if loadingState == .done { return }
        if blockOtherRequests { return }
        logger.debug("\(#function)")
        
        loadNextTask =  Task {
            blockOtherRequests = true
            if delay {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            if Task.isCancelled {
                blockOtherRequests = false
                return
            }
            if currentDayModel.timelines.isEmpty == false {
                let timeline =  currentDayModel.timelines.removeFirst()
                dayTimelineModels.append(timeline)
                blockOtherRequests = false
                
                if isContentFilledToScrollable == false {
                    displayedContentLength += timeline.content?.count ?? 0
                    loadNext()
                }
                
            } else {
                if Task.isCancelled {
                    blockOtherRequests = false
                    return
                }
                fetchNextDayTimelines()
            }
        }
    }
    
    
    private func fetchNextDayTimelines() {
        logger.debug("\(#function)")
        // delay some time, to load next day
        if remainingDaysToLoad.isEmpty {
            updateStatusMessage()
            blockOtherRequests = false
            return
        }
        fetchNextDayTask = Task {
            currentLoadingDate = remainingDaysToLoad.removeFirst()
            let dayTimelines = await prepareTimelines(for: currentLoadingDate)
            if Task.isCancelled {
                blockOtherRequests = false
                return
            }
            logger.debug("timelines for date: \(dayTimelines.count)")
            if dayTimelines.count > 0 {
                let newDayRow = DayTimelineModel(date: currentLoadingDate, timelines: dayTimelines)
                currentDayModel = newDayRow
                
                var timeline =  currentDayModel.timelines.removeFirst()
                timeline.setAsFirst()
                dayTimelineModels.append(timeline)
                
                blockOtherRequests = false
                
                if scrolledID == nil {
                    scrolledID = timeline.id
                }
                
//                if isContentFilledToScrollable == false {
//                    displayedContentLength += timeline.content?.count ?? 0
//                    if Task.isCancelled {
//                        return
//                    }
//                    loadNext()
//                }
            } else {
                // auto try next day
                blockOtherRequests = false
                if Task.isCancelled {
                    return
                }
                loadNext(false)
            }
        }
    }
    
    
    
    //    fileprivate func loadNextTillScreenFills() async {
    //        if initialLoadDone == false {
    //            logger.debug("\(#function)")
    //            for t in dayTimelineModels {
    //                displayedContentLength += t.content?.count ?? 0
    //            }
    //            if isContentFilledToScrollable == false {
    //                logger.debug("isContentFilledToScrollable")
    //                loadNext()
    ////                tryLoadNextDay()
    //            } else {
    //                initialLoadDone = true
    //            }
    //        }
    //    }
    
    
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
    
    func deleteHeaderIfRequired(date: Date) {
        logger.debug("\(#function)")
        let dayItemsCount = dayTimelineModels.filter { t in
            t.date == date
        }.count
        logger.debug("dayItemsCount: \(dayItemsCount)")
        if dayItemsCount == 1 {
            // means, only header existed. remove that also
            dayTimelineModels.removeAll { t in
                t.date == date
            }
        }
    }
    
    func discardTimelineChanges(info: Timeline) {
        logger.info("\(#function)")
        do {
            try timelineBusiness.discard(changeId: info.id, date: info.date, fileId: info.fileUUID)
            // remove from UI
            guard let index = dayTimelineModels.firstIndex(where: { $0.id == info.id }) else { return }
            
            // set next as first if same day
            if dayTimelineModels[index].isFirst {
                let nextIndex = index + 1
                if nextIndex < dayTimelineModels.count {
                    if dayTimelineModels[nextIndex].date == info.date {
                        dayTimelineModels[nextIndex].setAsFirst()
                    }
                }
            }
            
            dayTimelineModels.remove(at: index)
            
            //            dayTimelineModels.removeAll { t in
            //                t.id == info.id
            //            }
            //
            //            deleteHeaderIfRequired(date: info.date)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
}
