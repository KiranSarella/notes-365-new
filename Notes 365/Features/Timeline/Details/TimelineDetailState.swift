//
//  TimelineDetailState.swift
//  Notes 365
//
//  Created by kiran ipc on 03/10/23.
//

import Foundation
import SwiftData
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
    
    var timelineBusiness = TimelineBusiness()
    var calendarState = TimelineCalendarState.day(DayDate(date: Date()))
    
    var selectedDate = Date()
    
    // load more
    var canLoadMore = false
    var loadingDayChanges = false
    var loadingDate = Date()
    
    var currentState = CurrentState.loading
    
    var cancellable: Cancellable? = nil
    
    var dayIndexs = [DayIndex]()
    
    var timelineIndexes = [TimelineIndex]()
    
    
    var isFirstAppear = true
    var generatorTask: Task<(), Never>? = nil
    
    var canDelete: Bool {
        false
        //        dayDate.date.isSameDayAs(Date())
    }
    
    var cancellableSet = Set<AnyCancellable>()
    
    
    
    init() {
        timelineBusiness.registerNotebookChangesNotification()
    }
    
    func setToday() {
        selectedDate = Date()
    }
    
    deinit {
        cancellable?.cancel()
        timelineBusiness.removeNotebookChangesNotification()
    }
    
    func clearDisplay() {
        generatorTask?.cancel()
        DispatchQueue.main.async {
            self.timelineIndexes.removeAll()
            self.dayIndexs.removeAll()
        }
    }
    
    func startReloadingContent() {
        Task {
            clearDisplay()
            DispatchQueue.main.async {
                self.currentState = .loading
                self.canLoadMore = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // your code here
                switch self.calendarState {
                case .day(let dayDate):
                    self.startFetchingDayIndex(dayDate: dayDate)
                case .week(let weekDate):
                    self.startFetchingWeekIndex(weekDate: weekDate)
                case .month(let monthDate):
                    self.startFetchingMonthIndex(monthDate: monthDate)
                }
            }
        }
    }
    
    
    // MARK: - Timeline Index
    
    func startFetchingDayIndex(dayDate: DayDate) {
        print(#function, dayDate.date)
        if let result = self.timelineBusiness.fetchDayTimelineIndex(year: dayDate.date.getYear(), month: dayDate.date.getMonth(), day: dayDate.date.getDay()) {
            self.timelineIndexes.append(result)
            print(timelineIndexes.count)
            processFirstDay()
        } else {
            self.currentState = .empty
        }
    }
    
    func startFetchingWeekIndex(weekDate: WeekDate) {
        let date = weekDate.start
        print(#function, date)
        // why loop instead of between query
        // because a week might contain two months
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: date)!
            if let timelineIndex = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(),
                                                                               month: date.getMonth(),
                                                                               day: date.getDay()) {
                self.timelineIndexes.append(timelineIndex)
            }
        }
        
        print(timelineIndexes)
        
        if self.timelineIndexes.count > 0 {
            processFirstDay()
        } else {
            self.currentState = .empty
        }
    }
    
    func startFetchingMonthIndex(monthDate: MonthDate) {
        let date = monthDate.start
        print(#function, date)
        
        if let results = self.timelineBusiness.fetchMonthTimelineIndex(year: date.getYear(), month: date.getMonth()), results.count > 0 {
            self.timelineIndexes = results.sorted { $0.day < $1.day }
            print(timelineIndexes.count)
            processFirstDay()
        } else {
            self.currentState = .empty
        }
    }
    
    // MARK: - Day Note Changes
    
    func tryLoadMore() {
        
        // have to maintain queue? - what if day content is single line?
        if loadingDayChanges {
            return
        }
        processNextDay()
    }
    
    func processFirstDay() {
        print(#function)
        if timelineIndexes.count > 0 {
            // load first day
            Task {
                let dayIndex = await readDayDataOnly(timelineIndex: timelineIndexes.removeFirst())
                DispatchQueue.main.async {
                    self.dayIndexs.append(dayIndex)
                    self.currentState = .data
                }
                // can load more
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.timelineIndexes.count > 0 {
                        self.canLoadMore = true
                    }
                }
            }
        } else {
            canLoadMore = false
        }
    }
    
    func processNextDay() {
        print(#function)
        if timelineIndexes.count > 0 {
            // load first day
            Task {
                loadingDayChanges = true
                let dayIndex = await readDayDataOnly(timelineIndex: timelineIndexes.removeFirst())
                DispatchQueue.main.async {
                    self.dayIndexs.append(dayIndex)
                    self.loadingDayChanges = false
                }
            }
        } else {
            canLoadMore = false
        }
    }
    
    func readDayDataOnly(timelineIndex: TimelineIndex) async -> DayIndex {
        
        await withCheckedContinuation { continuation in
            
            let dayIndex = DayIndex(timelineIndex: timelineIndex)
            generatorTask = Task {
                for await timeline in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: timelineBusiness) {
                    if Task.isCancelled == true { return }
                    DispatchQueue.main.async {
                        dayIndex.timelines.append(timeline)
                    }
                }
                continuation.resume(returning: dayIndex)
            }
        }
    }
    
    // MARK: - Discard Note Changes
    func removeTimelineChanges(_ timeline: Timeline) {
        //        // remove from UI
        //        timelineList.removeAll { item in
        //            item.id == timeline.id
        //        }
        //
        //        if timelineList.count == 0 {
        //            currentState = .empty
        //        }
        
        // remove physical files
        //        timelineBusiness.removeTimelineChanges(timeline)
    }
    
}
