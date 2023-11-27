//
//  TimelineDetailState.swift
//  Notes 365
//
//  Created by kiran ipc on 03/10/23.
//

import Foundation
import SwiftUI
import Combine

extension Date {
    func getWeekStartEndDates() -> (Date, Date) {
        guard
            let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: self)
        else { fatalError() }
        
        let startDate = weekInterval.start
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        return (startDate, endDate)
    }
    
    func getMonthStartEndDates() -> (Date, Date) {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: self)
        else { fatalError() }
        
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        
        return (startDate, endDate)
    }
}

class ContentCache {
    var contentsDB = [UUID: AttributedString]()
}

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    /*
     limitation: more then 2 empty lines are treated as same
     */
    func fixLineBreaks() -> String {
        let pattern = #"\n[^$(?=\S)]+"#
        //    print(content)
        let out1 = self.replacingOccurrences(of: pattern, with: "##-##", options: .regularExpression, range: nil)
        //print(out1)
        let out2 = out1.replacingOccurrences(of: "\n", with: "##*##")
        //print(out2)
        let out3 = out2.replacingOccurrences(of: "##-##", with: "\n\n\n")
        //print(out3)
        let out4 = out3.replacingOccurrences(of: "##*##", with: "\n\n")
        //    print(out4)
        
        return out4
    }
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

public struct DayChanges: Identifiable {
    public let id = UUID()
    
    var timelineIndex: TimelineIndex
    var notes = [Timeline]()
}

//@Observable
//class TimelineCalendarState {
//    var calenderType: CalendarType = .day
//    var dayDate: DayDate? = DayDate(date: Date())
//    var weekDate: WeekDate? = WeekDate(date: Date())
//    var monthDate: MonthDate? = MonthDate(date: Date())
//}


enum TimelineCalendarState: Equatable {
    case day(DayDate)
    case week(WeekDate)
    case month(MonthDate)
}


extension DayNotebookChange {
    var timeline: Timeline {
        let fullPathInfo = NotebooksPathService.shared.path(for: notebookId)
        var t = Timeline(changesID: notebookId, 
                         fileUUID: notebookId,
                         fileName: fullPathInfo?.name ?? "",
                         filePath: fullPathInfo?.fullPath ?? "")
        t.content = content
        return t
    }
}


extension TimelineCalendarState {
    
    mutating func previousStep() {
        switch self {
        case .day(let dayDate):
            let dayDate = DayDate(date: Calendar.current.date(byAdding: .day, value: -1, to: dayDate.date)!)
            self = .day(dayDate)
        case .week(let weekDate):
            let weekDate = WeekDate(date: Calendar.current.date(byAdding: .day, value: -7, to: weekDate.start)!)
            self = .week(weekDate)
        case .month(let monthDate):
            let monthDate = MonthDate(date: Calendar.current.date(byAdding: .month, value: -1, to: monthDate.start)!)
            self = .month(monthDate)
        }
    }
    
    mutating func nextStep() {
        switch self {
        case .day(let dayDate):
            let dayDate = DayDate(date: Calendar.current.date(byAdding: .day, value: 1, to: dayDate.date)!)
            self = .day(dayDate)
        case .week(let weekDate):
            let weekDate = WeekDate(date: Calendar.current.date(byAdding: .day, value: 7, to: weekDate.start)!)
            self = .week(weekDate)
        case .month(let monthDate):
            let monthDate = MonthDate(date: Calendar.current.date(byAdding: .month, value: 1, to: monthDate.start)!)
            self = .month(monthDate)
        }
    }
    
}

@Observable
class TimelineDetailState {
    let timelineBusiness: TimelineInteractor
    
    var selectedDates = [Date()]
    
    var calendarState = TimelineCalendarState.day(DayDate(date: Date()))
    // load more
    var canLoadMore = false
    var loadingDayChanges = false
    var loadingDate = Date()
    var currentState = CurrentState.stop
    var cancellable: Cancellable? = nil
    var dayIndexs = [DayIndex]()
    var timelineIndexes = [TimelineIndex]()
    var timelines = [Timeline]()
    var isFirstAppear = true
    var generatorTask: Task<(), Never>? = nil
    var canDiscard: Bool {
        switch calendarState {
        case .day(let dayDate):
            return dayDate.date.isSameDayAs(Date())
        case .week(_):
            return false
        case .month(_):
            return false
        }
//        dayDate.date.isSameDayAs(Date())
    }
    var cancellableSet = Set<AnyCancellable>()
    var currentTaskID = UUID()
    init(timelineBusiness: TimelineInteractor) {
        self.timelineBusiness = timelineBusiness
//        getFirstAvailableTimelineDate()
    }
    
    func setToday() {
        calendarState = .day(DayDate(date: Date()))
    }
    
    func clearDisplay() {
        print(#function)
        generatorTask?.cancel()
        self.timelineIndexes.removeAll()
        self.dayIndexs.removeAll()
        currentTaskID = UUID()
        self.currentState = .stop
        self.canLoadMore = false
    }
    
    func loadDayContent() {
        Task {
            do {
                await NotebooksPathService.shared.refreshNotebooksInfo()
                let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: Date())
                timelines = results.map { $0.timeline }
            } catch let error {
                print(error)
            }
        }
    }
    
//    func getFirstAvailableTimelineDate() {
//        let firstEntryDate = timelineBusiness.getFirstAvailableTimelineDate()
//        logger.info("getFirstAvailableTimelineDate - \(firstEntryDate?.string(format: "yyyy-MM-dd") ?? "")")
//    }
    
   
    
    func startReloadingContent() {
//        print(#function)
//        Task {
//            clearDisplay()
//            self.currentState = .loading
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                // start fetching data
//                switch self.calendarState {
//                case .day(let dayDate):
//                    self.startFetchingDayIndex(dayDate: dayDate, reqID: self.currentTaskID)
//                case .week(let weekDate):
//                    self.startFetchingWeekIndex(weekDate: weekDate, reqID: self.currentTaskID)
//                case .month(let monthDate):
//                    self.startFetchingMonthIndex(monthDate: monthDate, reqID: self.currentTaskID)
//                }
//            }
//        }
    }
    
    
    // MARK: - Timeline Index
    
    func startFetchingDayIndex(dayDate: DayDate, reqID: UUID) {
//        print(#function, dayDate.date)
//        if let result = self.timelineBusiness.fetchDayTimelineIndex(year: dayDate.date.getYear(), month: dayDate.date.getMonth(), day: dayDate.date.getDay()) {
//            if reqID != currentTaskID {
//                return
//            }
//            self.timelineIndexes.append(result)
//            print("timelineIndexes: ", timelineIndexes.count)
//            print(result.id, result.changes)
//            processFirstDay(reqID: reqID)
//        } else {
//            self.currentState = .empty
//        }
    }
    
    func startFetchingWeekIndex(weekDate: WeekDate, reqID: UUID) {
//        let date = weekDate.start
//        print(#function, date)
//        // why loop instead of between query
//        // because a week might contain two months
//        for i in 0..<7 {
//            let date = Calendar.current.date(byAdding: .day, value: i, to: date)!
//            if let timelineIndex = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(),
//                                                                               month: date.getMonth(),
//                                                                               day: date.getDay()) {
//                if reqID != currentTaskID {
//                    return
//                }
//                self.timelineIndexes.append(timelineIndex)
//            }
//        }
//        
//        print("timelineIndexes: ", timelineIndexes.count)
//        
//        if self.timelineIndexes.count > 0 {
//            processFirstDay(reqID: reqID)
//        } else {
//            self.currentState = .empty
//        }
    }
    
    func startFetchingMonthIndex(monthDate: MonthDate, reqID: UUID) {
//        let date = monthDate.start
//        print(#function, date)
//        
//        if let results = self.timelineBusiness.fetchMonthTimelineIndex(year: date.getYear(), month: date.getMonth()), results.count > 0 {
//            
//            if reqID != currentTaskID {
//                return
//            }
//            self.timelineIndexes = results.sorted { $0.day < $1.day }
//            
//            print("timelineIndexes: ", timelineIndexes.count)
//            processFirstDay(reqID: reqID)
//        } else {
//            self.currentState = .empty
//        }
    }
    
    // MARK: - Day Note Changes
    
    func tryLoadMore() {
        print(#function, loadingDayChanges)
        // have to maintain queue? - what if day content is single line?
        if loadingDayChanges {
            return
        }
        processNextDay()
    }
    
    func processFirstDay(reqID: UUID) {
//        print(#function)
//        // load first day
//        self.generatorTask = Task {
//            
//            print("timelineIndexes: before - ", timelineIndexes.count)
//            if let current = timelineIndexes.first {
//                let dayIndex = await readDayDataOnly(timelineIndex: current)
//                
//                if reqID != currentTaskID {
//                    return
//                }
//                if timelineIndexes.count == 0 {
//                    return
//                }
//                
//                timelineIndexes.removeFirst()
//                print("timelineIndexes: after - ", timelineIndexes.count)
//                DispatchQueue.main.async {
//                    self.dayIndexs.append(dayIndex)
//                    self.currentState = .data
//                }
//                // can load more
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    if self.timelineIndexes.count > 0 {
//                        self.canLoadMore = true
//                    }
//                }
//            }
//            
//        }
    }
    
    func processNextDay() {
//        print(#function)
//        if timelineIndexes.count > 0 {
//            // load first day
//            self.generatorTask = Task {
//                loadingDayChanges = true
//                let dayIndex = await readDayDataOnly(timelineIndex: timelineIndexes.removeFirst())
//                DispatchQueue.main.async {
//                    self.dayIndexs.append(dayIndex)
//                    self.loadingDayChanges = false
//                }
//            }
//        } else {
//            canLoadMore = false
//        }
    }
    
    
//    func readDayDataOnly(timelineIndex: TimelineIndex) async -> DayIndex {
//        
//        print(#function)
//        print(timelineIndex.changes)
//        let dayIndex = DayIndex(timelineIndex: timelineIndex)
//        // prepare each note change item
//        for await timelineResult in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: self.timelineBusiness) where !Task.isCancelled {
//            if Task.isCancelled { break }
//            
////            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            
////            print("timelineResut: ", timelineResult?.fileName)
////            print(self.generatorTask?.isCancelled)
////            print(Task.isCancelled)
//            if let timelineResult = timelineResult {
//                dayIndex.timelines.append(timelineResult)
////                DispatchQueue.main.async {
////                    dayIndex.timelines.append(timelineResult)
////                }
//            }
//        }
//        // after processing all note changes in a day, return all data
////        continuation.resume(returning: dayIndex)
//        
//        print("self.generatorTask = nil")
////                self.generatorTask = nil
//        return dayIndex
//    }
    
//    func readDayDataOnly(timelineIndex: TimelineIndex) async -> DayIndex {
//        await withCheckedContinuation { continuation in
//            print(#function)
//            print(timelineIndex.changes)
//            let dayIndex = DayIndex(timelineIndex: timelineIndex)
//            self.generatorTask = Task.detached {
//                // prepare each note change item
//                for await timelineResult in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: self.timelineBusiness) where !Task.isCancelled {
//                    if Task.isCancelled { return }
////                    print("timelineResut: ", timelineResult?.fileName)
////                    print(self.generatorTask?.isCancelled)
////                    print(Task.isCancelled)
//                    if let timelineResult = timelineResult {
//                        DispatchQueue.main.async {
//                            dayIndex.timelines.append(timelineResult)
//                        }
//                    }
//                }
//                // after processing all note changes in a day, return all data
//                continuation.resume(returning: dayIndex)
//                print("self.generatorTask = nil")
////                self.generatorTask = nil
//            }
//        }
//    }
    
    // MARK: - Discard Note Changes
    func removeTimelineChanges(_ timeline: Timeline) {
        // remove from UI
        dayIndexs.first?.timelines.removeAll { item in
            item.id == timeline.id
        }

        var timelineIndexId: UUID?
        
        if dayIndexs.first?.timelines.count == 0 {
            // delete timelineindex also
            timelineIndexId = dayIndexs.first?.id
            
            dayIndexs.removeAll()
            currentState = .empty
        }

        // remove physical files
//        timelineBusiness.removeTimelineChanges(timeline, timelineIndexId)
    }
    
}
