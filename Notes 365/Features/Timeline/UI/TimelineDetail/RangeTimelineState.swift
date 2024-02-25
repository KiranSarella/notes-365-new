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
    var currentLoadingDate = DateTime.now().dayAfter
    var currentDayModel = DayTimelineModel(date: DateTime.now())
    //    var currentDateLoadingState = CurrentDateLoadingState(date: DateTime.now(), timmelinesCount: 0)
    var loadingState: LoadingState = .notStarted
    //    var currentDayLoaded = false
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    
    var initialLoadDone = false
    var scrolledID: Timeline.ID?
    //    var scrolledTimelineID: Timeline.ID?
    var displayedContentLength: Int = 0
    
    let initialLoadCount: Int = 8000 // safe side keeping more.
    // better to get accurate value based on theme font size
    
    var blockOtherRequests = false
    
    // folder related
    private var folderId: UUID = UUID()
    private var folderItems = Set<UUID>()
    
    private(set) var currentFilterType: TopFilterType = .dateRange
    
    func beginNewLoading(filter: any TopFilterOption) {
        logger.debug("\(#function)")
        if let filter = filter as? TimelineDateRange {
            startloading(days: filter.dateRange)
        } else if let filter = filter as? TimelineFolderRange {
            startloadingFolderItems(folderId: filter.folderId)
        }
    }
    
    private func startloading(days: [Date]) {
        logger.info("startLoadingDays - \(days)")
        resetFields()
        currentFilterType = .dateRange
        remainingDaysToLoad = days
        loadNext()
    }
    
    private var startFolderTask: Task<(), Never>?
    
    private func startloadingFolderItems(folderId: UUID) {
        logger.info("\(#function)")
        resetFields()
        currentFilterType = .folder
        self.folderId = folderId
        
        startFolderTask?.cancel()
        startFolderTask = Task {
            let fileIds = await NotebooksPathService.shared.getAllChildFiles(folderId: folderId)
            if Task.isCancelled { return }
            folderItems = Set(fileIds)
            loadNext()
        }
    }
    
    
    func resetFields() {
        loadNextTask?.cancel()
        fetchNextDayTask?.cancel()
        dayTimelineModels.removeAll()
        remainingDaysToLoad.removeAll()
        scrolledID = nil
        blockOtherRequests = false
        currentLoadingDate = DateTime.now().dayAfter
        currentDayModel = DayTimelineModel(date: DateTime.now())
        
        loadingState = .loading
        displayedContentLength = 0
        initialLoadDone = false
        
        // folder
        folderId = UUID()
        folderItems.removeAll()
    }
    
    var isContentFilledToScrollable: Bool {
        logger.debug("contentLength: \(self.displayedContentLength)")
        return displayedContentLength > initialLoadCount
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
    
    var loadNextTask: Task<(), Never>?
    var fetchNextDayTask: Task<(), Never>?
    
    func loadNext(_ delay: Bool = true) {
        if loadingState == .done { return }
        if blockOtherRequests { return }
        logger.debug("\(#function)")
        
        loadNextTask =  Task { @MainActor in
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
                    if Task.isCancelled {
                        return
                    }
                    loadNext()
                }
            } else {
                if Task.isCancelled {
                    blockOtherRequests = false
                    return
                }
                switch currentFilterType {
                case .dateRange:
                    fetchNextDayTimelines()
                case .folder:
                    fetchNextFolderDayTimelines()
                case .separator:
                    break
                }
            }
        }
    }
   
    private func fetchNextDayTimelines() {
        logger.debug("\(#function)")
        
        fetchNextDayTask = Task { @MainActor in
            if remainingDaysToLoad.isEmpty {
                updateStatusMessage()
                blockOtherRequests = false
                return
            }
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
                let finalTimeline = timeline
                dayTimelineModels.append(finalTimeline)
                blockOtherRequests = false
                
                if scrolledID == nil {
                    // after first item
                    displayedContentLength += timeline.content?.count ?? 0
                    if Task.isCancelled {
                        return
                    }
                    scrolledID = timeline.id
                } else {
                    // from 2nd to scrollable limit
                    if isContentFilledToScrollable == false {
                        displayedContentLength += timeline.content?.count ?? 0
                        if Task.isCancelled {
                            return
                        }
                        loadNext()
                    }
                }

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
    
    
    var anyAvailableFolderDays: Bool {
        currentLoadingDate > SharedData.shared.firstKnowDate
    }
    
    private func fetchNextFolderDayTimelines() {
        logger.debug("\(#function)")
        
        fetchNextDayTask = Task { @MainActor in
            if anyAvailableFolderDays == false {
                updateStatusMessage()
                blockOtherRequests = false
                return
            }
            currentLoadingDate = currentLoadingDate.dayBefore
            let allItems = await prepareTimelines(for: currentLoadingDate)
            // include folder items only
            let dayTimelines = allItems.filter { t in
                folderItems.contains(t.fileUUID)
            }
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
                let finalTimeline = timeline
                dayTimelineModels.append(finalTimeline)
                blockOtherRequests = false
                
                if scrolledID == nil {
                    // after first item
                    displayedContentLength += timeline.content?.count ?? 0
                    if Task.isCancelled {
                        return
                    }
                    scrolledID = timeline.id
                } else {
                    // from 2nd to scrollable limit
                    if isContentFilledToScrollable == false {
                        displayedContentLength += timeline.content?.count ?? 0
                        if Task.isCancelled {
                            return
                        }
                        loadNext()
                    }
                }

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
    

    func prepareTimelines(for date: Date) async -> [Timeline] {
        logger.debug("load day: \(date)")
        var timelines = [Timeline]()
        do {
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
    
    fileprivate func setNextAsFirstDayIfSameDay(_ index: Array<Timeline>.Index, _ date: Date) {
        // set next as first if same day
        if dayTimelineModels[index].isFirst {
            let nextIndex = index + 1
            if nextIndex < dayTimelineModels.count {
                if dayTimelineModels[nextIndex].date == date {
                    dayTimelineModels[nextIndex].setAsFirst()
                }
            }
        }
    }
    
    func discardTimelineChanges(info: Timeline) {
        logger.info("\(#function)")
        do {
            try timelineBusiness.discard(changeId: info.id, date: info.date, fileId: info.fileUUID)
            // remove from UI
            guard let index = dayTimelineModels.firstIndex(where: { $0.id == info.id }) else { return }
            
            setNextAsFirstDayIfSameDay(index, info.date)
            
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
    
    func refreshOpenedTimelineContent(_ newValue: inout Timeline?) {
        guard let openTimeline = newValue else { return }
        // if today
        if !openTimeline.date.isToday {
            newValue = nil
            return
        }
        
        guard let index = dayTimelineModels.firstIndex(where: { $0.id == openTimeline.id }) else { return }
        logger.debug("\(#function)")
        
        do {
            if let newChanges = try timelineBusiness.fetchDayTimelineNoteChanges(id: openTimeline.id) {
                Task { @MainActor in
                    dayTimelineModels[index].content = newChanges.content
                }
            } else {
                Task { @MainActor in
                    // no record
                    setNextAsFirstDayIfSameDay(index, openTimeline.date)
                    dayTimelineModels.remove(at: index)
                }
            }
        } catch {
            logger.error("\(error)")
            Task { @MainActor in
                // no record found
                setNextAsFirstDayIfSameDay(index, openTimeline.date)
                dayTimelineModels.remove(at: index)
            }
        }
        // deselect
        newValue = nil
    }
    
}
