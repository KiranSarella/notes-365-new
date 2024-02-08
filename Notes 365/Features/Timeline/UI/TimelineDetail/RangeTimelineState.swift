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



enum TimelineCellType {
    case date
    case path
    case content
}

struct TimelineCell: Identifiable {
    var id: UUID
    var type: TimelineCellType
    var fileUUID: UUID = UUID()
    // date
    var date: Date = DateTime.now()
    // pathBar
    var fileName: String = ""
    var filePath: String = ""
    // content
    var content: String?
}

@Observable
class RangeTimelineNewState {
    var items = [TimelineCell]()
    
    var dateCell: TimelineCell {
        TimelineCell(id: UUID(), type: .date, date: DateTime.now())
    }
    
    var pathCell: TimelineCell {
        TimelineCell(id: UUID(), type: .path, fileUUID: UUID(), fileName: "Ornare Tellus", filePath: "path > path to")
    }
    
    var contentCell: TimelineCell {
        TimelineCell(id: UUID(), type: .content, content: "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Lorem ipsum dolor sit amet, consectetur Donec id elit non mi porta gravida at eget metus. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. adipiscing elit. Vestibulum id ligula porta felis euismod semper.")
    }
    
    func loadItems() {
        
        items.append(dateCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        
        items.append(dateCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        
        items.append(dateCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        
        items.append(dateCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        items.append(pathCell)
        items.append(contentCell)
        
    }
    
}


@Observable
class RangeTimelineState {
    var givenDays = [Date]()
    var dayTimelineModels = [DayTimelineModel]()
    var currentLoadingDate = DateTime.now()
    var currentDateLoadingState = CurrentDateLoadingState(date: DateTime.now(), timmelinesCount: 0)
//    var daysContentExists:Set<Bool> = []
    var canLoadMore = true
    var statusMessage: String?
    var currentDayLoaded = false
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    
    var initialLoadDone = false
    var scrolledID: DayTimelineModel.ID?
    var contentLength: Int = 0
    
    func startloading(days: [Date]) {
        logger.info("startLoadingDays - \(days)")
        resetFields()
        givenDays = days
        tryLoadNextDay()
    }
    
    func resetFields() {
        dayTimelineModels.removeAll()
        currentLoadingDate = DateTime.now()
//        daysContentExists = []
        canLoadMore = true
        statusMessage = "Loading.."
        contentLength = 0
        initialLoadDone = false
    }
    
    var isContentFilledToScrollable: Bool {
        logger.debug("contentLength: \(self.contentLength)")
        return contentLength > 3000
    }
    
//    func tryLoadMore() {
//        logger.debug("tryLoadMore - currentDayLoaded: \(self.currentDayLoaded)")
//        // have to maintain queue? - what if day content is single line?
//        if currentDayLoaded == false {
//            return
//        }
//        loadNextDay()
//    }
    
    var anyDaysAvailable: Bool {
        if givenDays.count == 0 {
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
    
    func tryLoadNextDay() {
        logger.debug("\(#function)")
        
        if canLoadMore == false { return }
        
        if anyDaysAvailable {
            loadNextDay()
        }
    }
    
    
    
    private func loadNextDay() {
        logger.debug("\(#function)")
        
        currentLoadingDate = givenDays.removeFirst()
        currentDayLoaded = false
        Task {
            let dayTimelines = await prepareTimelines(for: currentLoadingDate)
            logger.debug("timelines for date: \(self.currentDayLoaded) \(dayTimelines.count)")
            if dayTimelines.count > 0 {
                let newDayRow = DayTimelineModel(date: currentLoadingDate, timelines: dayTimelines)
                dayTimelineModels.append(newDayRow)
                
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
    
    func prepareTimelines(for date: Date) async -> [Timeline] {
        logger.debug("load day: \(date)")
        var timelines = [Timeline]()
        do {
//            await NotebooksPathService.shared.refreshNotebooksInfo()
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
