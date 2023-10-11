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
            return "loading.."
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


@Observable
class TimelineDetailState {
    
    var selectedDate = Date()
    
    // load more
    var canLoadMore = false
    var loadingDate = Date()
    
    var currentState = CurrentState.loading
//    var dayChangesList = [DayChanges]()
//    var generatorTask: Task<(), Never>? = nil
    
    var cancellable: Cancellable? = nil
    
    var days = [DayIndex]()
    var timelineBusiness = TimelineBusiness()
    var isFirstAppear = true
    var generatorTask: Task<(), Never>? = nil
    
    var canDelete: Bool {
        false
//        dayDate.date.isSameDayAs(Date())
    }
    
    var cancellableSet = Set<AnyCancellable>()
    
    var displayngCalendarType: CalendarType = .day
    
    var calendarState = CalendarState()
    
    init() {
        // observe changes
        observeMonthChanges()
        
        timelineBusiness.registerNotebookChangesNotification()
        
//        fetchAllTimelineIndexList()
    }
    
    
    
    func setToday() {
        selectedDate = Date()
    }
    
    func observeMonthChanges() {
//        cancellable = CalendarState.shared.$monthDate
//            .receive(on: DispatchQueue.main)
//            .sink { newMonthDate in
//                self.monthDate = newMonthDate
//            }
    }
    
    deinit {
        cancellable?.cancel()
        timelineBusiness.removeNotebookChangesNotification()
    }
    
//    func readData(_ date: Date) {
//        currentState = .loading
//        dayChangesList.removeAll()
//        
//        guard let timelineContents = timelineBusiness.fetchDayTimeline(for: date.getYear(), date.getMonth(), date.getDay()) else { return }
//        
//        let groupedList = Dictionary(grouping: timelineContents,
//                                     by: { $0.date })
////
//        print(groupedList)
//        
//        for day in groupedList.keys.sorted(by: { $0 > $1 }) {
//            // load notechange for each day
//            guard let contents = groupedList[day] else { return }
//            
//            var timelines = [Timeline]()
//            for timelineContent in contents {
//                timelines.append(timelineContent.getTimeline())
//            }
//            
//            let dayChanges = DayChanges(notes: timelines, date: day, metadata: "")
//            dayChangesList.append(dayChanges)
//        }
//        
//        currentState = .data
//    }
    
//    func fetchPreviousDate() {
//        loadingDate = loadingDate.dayBefore
//        if let dayChanges = fetchData(for: loadingDate) {
//            dayChangesList.append(dayChanges)
//        } else {
//            canLoadMore = false
//        }
//    }
//    
//    func fetchData(for date: Date) -> DayChanges? {
//        
//        guard 
//            let timelineContents = timelineBusiness.fetchDayTimeline(for: date.getYear(), date.getMonth(), date.getDay()),
//            timelineContents.count > 0
//        else { return nil }
//        
//        var timelines = [Timeline]()
//        for timelineContent in timelineContents {
//            timelines.append(timelineContent.getTimeline())
//        }
//        
//        return DayChanges(notes: timelines, date: date, metadata: "")
//    }
    
    func clearDisplay() {
        self.days.removeAll()
    }
    
//    func fetchAllTimelineIndexList() {
//        
//        DispatchQueue.main.async {
//            self.currentState = .loading
//            self.timelineIndexList.removeAll()
//            
//            if let results = self.timelineBusiness.fetchAllTimelineIndex(), results.count > 0 {
//                self.timelineIndexList = results.map { DayIndex(timelineIndex: $0) }
//                self.currentState = .data
//            } else {
//                self.currentState = .empty
//            }
//        }
//    }
    
    
    func loadContent(_ calendarType: CalendarType, _ date: Date) {
        
        clearDisplay()
        
        switch calendarType {
        case .day:
            // day
            fetchDayTimelineIndexList(date)
        case .week:
            // week
            fetchWeekTimelineIndexList(date)
        case .month:
            // month
            fetchMonthTimelineIndexList(date)
        }
        
    }
    
    
    func fetchDayTimelineIndexList(_ date: Date) {
        print(#function, date)
        DispatchQueue.main.async {
            self.currentState = .loading
            self.days.removeAll()
            
            if let result = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(), month: date.getMonth(), day: date.getDay()) {
                self.days = [DayIndex(timelineIndex: result)]
                self.currentState = .data
            } else {
                self.currentState = .empty
            }
        }
    }
    
    
    func fetchWeekTimelineIndexList(_ startDate: Date) {
        print(#function, startDate)
        DispatchQueue.main.async {
            self.currentState = .loading
            self.days.removeAll()

            // why loop instead of between query
            // because a week might contain two months
            for i in 0..<7 {
                let date = Calendar.current.date(byAdding: .day, value: i, to: startDate)!
                if let result = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(), month: date.getMonth(), day: date.getDay()) {
                    self.days.append(DayIndex(timelineIndex: result))
                }
            }
            
            if self.days.count > 0 {
                self.currentState = .data
            } else {
                self.currentState = .empty
            }
        }
    }
    
    
    func fetchMonthTimelineIndexList(_ date: Date) {
        print(#function, date)
        DispatchQueue.main.async {
            self.currentState = .loading
            self.days.removeAll()
            
            if let results = self.timelineBusiness.fetchMonthTimelineIndex(year: date.getYear(), month: date.getMonth()), results.count > 0 {
                self.days = results
                                            .sorted { $0.day < $1.day }
                                            .map { DayIndex(timelineIndex: $0) }
                self.currentState = .data
            } else {
                self.currentState = .empty
            }
        }
    }
    
    
//    func fetchTimelineIndexList() {
//        
//        if let results = timelineBusiness.fetchTimelineIndex(after: timelineIndexDate), results.count > 0 {
//            timelineIndexList = results
//            timelineIndexDate = results.last!.date.dayBefore
//        } else {
//            isLoadMoreTimelineIndex = false
//        }
//        
//    }
 
    
    // MARK: - Day
    
    
    func readDayData(dayDate: DayDate) -> Bool {
        currentState = .loading

        guard let timelineIndex = timelineBusiness.fetchDayTimelineIndex(year: dayDate.date.getYear(), month: dayDate.date.getMonth(), day: dayDate.date.getDay()) else {
            currentState = .empty
            return false
        }
        let dayIndex = DayIndex(timelineIndex: timelineIndex)
        
        generatorTask = Task {
            
            for await timeline in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: timelineBusiness) {
                if Task.isCancelled == true { return }
                DispatchQueue.main.async {
                    dayIndex.timelines.append(timeline)
                }
            }
            
            DispatchQueue.main.async {
                self.days.append(dayIndex)
                self.currentState = .data
            }
        }
        
        return true
    }
    
    func readDayDataOnly(timelineIndex: TimelineIndex) {
        currentState = .loading

        let dayIndex = DayIndex(timelineIndex: timelineIndex)
        
        generatorTask = Task {
            
            for await timeline in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: timelineBusiness) {
                if Task.isCancelled == true { return }
                DispatchQueue.main.async {
                    dayIndex.timelines.append(timeline)
                }
            }
            
            DispatchQueue.main.async {
                self.days.append(dayIndex)
                self.currentState = .data
            }
        }
    }
    
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
    
    
    // MARK: - Week
    
    var weekDays = [TimelineIndex]()
    
    func readWeekData(weekDate: WeekDate) {
        let date = weekDate.start
        currentState = .loading
        self.canLoadMore = false
        self.days.removeAll()
        self.weekDays.removeAll()
        
        // why loop instead of between query
        // because a week might contain two months
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: date)!
            if let timelineIndex = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(), 
                                                                               month: date.getMonth(),
                                                                               day: date.getDay()) {
                self.weekDays.append(timelineIndex)
            }
        }
        
        print(weekDays)
        
        if self.weekDays.count > 0 {
            self.currentState = .data
            processNextDay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.canLoadMore = true
            }
        } else {
            self.currentState = .empty
        }
    }
    
    func readMonthData(monthDate: MonthDate) {
        let date = monthDate.start
        currentState = .loading
        self.canLoadMore = false
        self.days.removeAll()
        self.weekDays.removeAll()
        
        if let results = self.timelineBusiness.fetchMonthTimelineIndex(year: date.getYear(), month: date.getMonth()), results.count > 0 {
            self.weekDays = results.sorted { $0.day < $1.day }
            print(weekDays.count)
            self.currentState = .data
            processNextDay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.canLoadMore = true
            }
        } else {
            self.currentState = .empty
        }
    }
    
    func processNextDay() {
        print(#function)
        if weekDays.count > 0 {
            // load first day
            readDayDataOnly(timelineIndex: weekDays.removeFirst())
        } else {
            canLoadMore = false
        }
    }
    
    
    // load more
    
    func tryLoadMore() {
        
        switch displayngCalendarType {
        case .day:
            break
        case .week:
            processNextDay()
        case .month:
            processNextDay()
        }
        
    }
    
}
