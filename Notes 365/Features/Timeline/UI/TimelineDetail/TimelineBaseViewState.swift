//
//  TimelineDetailState.swift
//  Notes 365
//
//  Created by kiran ipc on 03/10/23.
//

import Foundation
import SwiftUI
import Combine


enum TimelineDateRangeType {
    case today
    case daysAgo
    case calendar
}


extension Date {
    func startOfMonth() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps)!
    }
    
    func endOfMonth() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        let date = cal.date(from: comps)!
        let lastDayOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: date)!
        return lastDayOfMonth
    }
    
    func getDaysOfMonth() -> [Date] {
        
        //get the current Calendar for our calculations
        let cal = Calendar.current
        //get the days in the month as a range, e.g. 1..<32 for March
        let monthRange = cal.range(of: .day, in: .month, for: self)!
        //get first day of the month
        let comps = cal.dateComponents([.year, .month], from: self)
        //start with the first day
        //building a date from just a year and a month gets us day 1
        var date = cal.date(from: comps)!
        
        //somewhere to store our output
        var dates: [Date] = []
        //loop thru the days of the month
        for _ in monthRange {
            //add to our output array...
            dates.append(date)
            //and increment the day
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }
}



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
        let isDeleted = await NotebooksPathService.shared.isDeletedFile(uuid: notebookId)
//        let fullPathInfo = await NotebooksPathService.shared.path(for: notebookId)
//        let fullPathInfo: FullPathInfo? = FullPathInfo(id: notebookId, name: "", fullPath: "")
        var t = Timeline(id: id,
                         fileUUID: notebookId,
                         fileName: fileName ?? "",
                         filePath: "", 
                         date: date,
                         updatedTime: updatedTime, 
                         isDeleted: isDeleted)
        t.content = content
        return t
    }
}

enum TopFilterType {
    case dateRange
    case folder
    case separator
    
    var icon: String {
        switch self {
        case .dateRange:
            "calendar"
        case .folder:
            "folder"
        case .separator:
            ""
        }
    }
    
    var iconColor: Color {
        switch self {
        case .dateRange:
//            Color("icon_purple", bundle: nil)
//            Color.green
            Color(hex: 0xDA9100)
//            Color(hex: 0xF5BF03)
        case .folder:
            Color(hex: 0xB76E79)
//            Color.purple
//            Color("icon_red", bundle: nil)
//            Color.cyan
        case .separator:
            Color.red
        }
    }
}

protocol TopFilterOption: Identifiable, Equatable {
    var id: UUID { get set }
    var title: String { get set }
    var filterType: TopFilterType { get set }
}

struct TimelineDateRange: TopFilterOption {
    var id = UUID()
    var title: String
    var filterType: TopFilterType = .dateRange
    
    let type: TimelineDateRangeType
    let date: Date
    var dateRange = [Date]()
}

struct TimelineFolderRange: TopFilterOption {
    var id: UUID
    var title: String
    var filterType: TopFilterType = .folder
    
    let folderId: UUID
}

struct SeperatorOption: TopFilterOption {
    var id = UUID()
    var title: String = ""
    var filterType: TopFilterType = .separator
}

@Observable
class TimelineBaseViewState {
    let timelineBusiness: TimelineInteractor
    var currentState = CurrentState.stop
//    var selectedDates: [Date] = []
    
    var filterOptions = [any TopFilterOption]()
    var selectedFilterOption: (any TopFilterOption) = TimelineDateRange(title: "Today", type: .today, date: DateTime.now())
    var loadedDate: Date = DateTime.now()
   
    var openTimeline: Timeline?
    
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
                if let first = filterOptions.first {
                    selectedFilterOption = first
                }
                // append top folders
                // add seperator
                let seperator = SeperatorOption()
                filterOptions.append(seperator)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                filterOptions.append(contentsOf: await constructTopLevelFolders())
                loadedDate = DateTime.now()
                logger.debug("dateRanges.count - \(self.filterOptions.count)")
            }
        } else {
            logger.debug("only refreshing folders")
            // only refresh folders
            Task { @MainActor in
                
                filterOptions.removeAll { f in
                    f.filterType == .folder
                }
                
                filterOptions.append(contentsOf: await constructTopLevelFolders())
//                loadedDate = DateTime.now()
                logger.debug("dateRanges.count - \(self.filterOptions.count)")
                
                if selectedFilterOption.filterType == .folder {
                    let contains = filterOptions.contains(where: { f in
                        f.id == selectedFilterOption.id
                    })
                    
                    if contains {
                        let buffer = selectedFilterOption
                        selectedFilterOption = TimelineDateRange(title: "Today", type: .today, date: DateTime.now())
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        selectedFilterOption = buffer
                    } else {
                        if let first = filterOptions.first {
                            selectedFilterOption = first
                        }
                    }
                }
                
                
                
//                if let first = filterOptions.first {
//                    selectedFilterOption = first
//                }
            }
        }
    }
    
    func constructDateRanges() -> [TimelineDateRange] {
        logger.info("constructDateRanges")
        var ranges = [TimelineDateRange]()
        
        var today = TimelineDateRange(title: "Today", type: .today, date: DateTime.now())
        today.dateRange = [today.date]
        ranges.append(today)
        
        var yesderday = TimelineDateRange(title: "Yesterday", type: .daysAgo, date: DateTime.now().dayBefore)
        yesderday.dateRange = [yesderday.date]
        ranges.append(yesderday)
        
        
        let fibDays = fibonacciSeries(upTo: 365)
        for fibDay in fibDays {
            let agoDate = getAgoDate(value: fibDay)
            var timelineDate = TimelineDateRange(title: "\(fibDay) days ago", type: .daysAgo, date: agoDate)
            timelineDate.dateRange = [agoDate]
            ranges.append(timelineDate)
        }
        
        // last year same day
        let yearAgoDate = Calendar.current.date(byAdding: .year, value: -1, to: DateTime.now())!
        var timelineDate = TimelineDateRange(title: "a year ago", type: .daysAgo, date: yearAgoDate)
        timelineDate.dateRange = [yearAgoDate]
        ranges.append(timelineDate)
        
        return ranges
    }
    
    func getAgoDate(value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -value, to: DateTime.now())!
    }
    
    func fibonacciSeries(upTo limit: Int) -> [Int] {
        var sequence = [3, 5]
        while sequence.last! < limit {
            let nextNumber = sequence[sequence.count - 1] + sequence[sequence.count - 2]
            if nextNumber < limit {
                sequence.append(nextNumber)
            } else {
                break
            }
        }
        return sequence
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
    
//    func getDates(for dateRange: TimelineDateRange) -> [Date] {
//        switch dateRange.type {
//        case .today:
//            return [DateTime.now()]
//        case .previousSevenDays:
//            var today = DateTime.now()
//            var dates = [Date]()
//            for _ in 0..<7 {
//                today = today.dayBefore
//                dates.append(today)
//            }
//            return dates
//        case .month:
//            return dateRange.date.getDaysOfMonth()
//        case .dynamic:
//            return []
//        }
//    }
//    
    func constructTopLevelFolders() async -> [TimelineFolderRange] {
        logger.debug("\(#function)")
        let topLevel = await NotebooksPathService.shared.folders.filter { nb in
            nb.parentId == nil && nb.deletedDate == nil
        }
        
        for op in topLevel {
            logger.debug("\(op.name)")
        }
        
        return topLevel
            .map { $0.timelineFolderRange }
            .sorted { t1, t2 in
                t1.title < t2.title
            }
    }
}

extension NotebookB {
    var timelineFolderRange: TimelineFolderRange {
        TimelineFolderRange(id: id, title: name, folderId: id)
    }
}
