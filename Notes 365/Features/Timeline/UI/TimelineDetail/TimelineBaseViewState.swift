//
//  TimelineDetailState.swift
//  Notes 365
//
//  Created by kiran ipc on 03/10/23.
//

import Foundation
import SwiftUI
import Combine

class ContentCache {
    var contentsDB = [UUID: AttributedString]()
}


enum CurrentState {
    case stop
    case loading
    case data
    case empty
    
    var message: String {
        switch self {
        case .loading:
            return "Loading.."
        case .data:
            return ""
        case .empty:
            return "No notes were added/updated on the given day(s)"
        case .stop:
            return ""
        }
    }
}

enum SpeechState {
    case stopped
    case playing
    case paused
    
    var buttonTitle: String {
        switch self {
        case .stopped:
            return "Speak"
        case .playing:
            return "Pause"
        case .paused:
            return "Continue"
        }
    }
}


extension TimelineB {
    func getTimeline(date: Date) async -> Timeline {
        let fileName = await NotebooksPathService.shared.fileName(for: notebookId)
//        let fullPathInfo = await NotebooksPathService.shared.path(for: notebookId)
        let fullPathInfo: FullPathInfo? = FullPathInfo(id: notebookId, name: "test 1", fullPath: "")
        var t = Timeline(id: id,
                         fileUUID: notebookId,
                         fileName: fileName ?? "",
                         filePath: fullPathInfo?.fullPath ?? "", date: date)
        t.content = content
        return t
    }
}


@Observable
class TimelineBaseViewState {
    let timelineBusiness: TimelineInteractor
    var currentState = CurrentState.stop
//    var selectedDates: [Date] = []
    
    var filterOptions = [any TopFilterOption]()
    var selectedFilterOption: (any TopFilterOption) = TimelineDateRange(title: "Today", filterType: .dateRange, type: .today, date: DateTime.now())
    var loadedDate: Date = DateTime.now()
   
    init(timelineBusiness: TimelineInteractor) {
        self.timelineBusiness = timelineBusiness
    }
    
    func loadFirstKnowDate() {
        SharedData.shared.firstKnowDate = self.timelineBusiness.getFirstAvailableTimelineDate() ?? DateTime.now().dayBefore
    }
    
    func constructFilterItemsIfRequired() {
        if filterOptions.isEmpty || !loadedDate.isSameDayAs(DateTime.now()) {
            Task { @MainActor in
                filterOptions = constructDateRanges()
                filterOptions.append(contentsOf: await conctructTopLevelFolders())
                loadedDate = DateTime.now()
                logger.debug("dateRanges.count - \(self.filterOptions.count)")
                
                if let first = filterOptions.first {
                    selectedFilterOption = first
                }
            }
        }
    }
    
    func constructDateRanges() -> [TimelineDateRange] {
        logger.info("constructDateRanges")
        var ranges = [TimelineDateRange]()
        
        let today = TimelineDateRange(title: "Today", filterType: .dateRange, type: .today, date: DateTime.now())
        ranges.append(today)
        
        // add previous 7 days by default
        let sevenDays = TimelineDateRange(title: "Previous 7 Days", filterType: .dateRange, type: .previousSevenDays, date: DateTime.now().dayBefore)
        ranges.append(sevenDays)
        
        // add current month by default
        var currenMonth = DateTime.now().startOfMonth()
        let currentMonthRange = TimelineDateRange(title: "This Month", filterType: .dateRange, type: .month, date: currenMonth)
        ranges.append(currentMonthRange)
        
        // populate previous 6 months
        currenMonth = currenMonth.monthBefore
        var count = 6
        while count > 0 {
            let monthRange = TimelineDateRange(title: currenMonth.monthName, filterType: .dateRange, type: .month, date: currenMonth)
            ranges.append(monthRange)
            currenMonth = currenMonth.monthBefore
            count -= 1
        }
        
        return ranges
    }
    
    func isSelected(input: any TopFilterOption) -> Bool {
        
        if let input = input as? TimelineDateRange {
            if let selectedDateRange = selectedFilterOption as? TimelineDateRange {
                return selectedDateRange.id == input.id
            }
        } else if let input = input as? TimelineFolderRange {
            if let selectedFolderRange = selectedFilterOption as? TimelineFolderRange {
                return selectedFolderRange.id == input.id
            }
        }
        
        return false
    }
    
    func getDates(for dateRange: TimelineDateRange) -> [Date] {
        switch dateRange.type {
        case .today:
            return [DateTime.now()]
        case .previousSevenDays:
            var today = DateTime.now()
            var dates = [Date]()
            for _ in 0..<7 {
                today = today.dayBefore
                dates.append(today)
            }
            return dates
        case .month:
            return dateRange.date.getDaysOfMonth()
        case .dynamic:
            return []
        }
    }
    
    func conctructTopLevelFolders() async -> [TimelineFolderRange] {
        
        let topLevel = await NotebooksPathService.shared.foldersInfoCache.filter { nb in
            nb.parentId == nil && nb.deletedDate == nil
        }
        
        return topLevel.map { $0.timelineFolderRange }
    }
}

extension NotebookB {
    var timelineFolderRange: TimelineFolderRange {
        TimelineFolderRange(title: name, filterType: .folder, folderId: id)
    }
}
