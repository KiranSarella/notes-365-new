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
    
    var notes = [Timeline]()
    let date: Date
    let metadata: String
}


@Observable
class TimelineDetailState {
    
    var selectedDate = Date()
    
    // load more
    var canLoadMore = true
    var loadingDate = Date()
    
    var currentState = CurrentState.loading
    var dayChangesList = [DayChanges]()
    var generatorTask: Task<(), Never>? = nil
    
    var cancellable: Cancellable? = nil
    
    var timelineBusiness = TimelineBusiness(path: URL(string: "test")!)
    
    init() {
        // observe changes
        observeMonthChanges()
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
    }
    
    func readData(_ date: Date) {
        currentState = .loading
        dayChangesList.removeAll()
        
        guard let timelineContents = timelineBusiness.fetchDayTimeline(for: date.getYear(), date.getMonth(), date.getDay()) else { return }
        
//        let timelineContents = timelineBusiness.fetchTimeline(for: monthDate.start.getYear()) ?? []
        
        let groupedList = Dictionary(grouping: timelineContents,
                                     by: { $0.date })
//
        print(groupedList)
        
        for day in groupedList.keys.sorted(by: { $0 > $1 }) {
            // load notechange for each day
            guard let contents = groupedList[day] else { return }
            
            var timelines = [Timeline]()
            for timelineContent in contents {
                timelines.append(timelineContent.getTimeline())
            }
            
            let dayChanges = DayChanges(notes: timelines, date: day, metadata: "")
            dayChangesList.append(dayChanges)
        }
        
        currentState = .data
    }
    
    func fetchPreviousDate() {
        loadingDate = loadingDate.dayBefore
        if let dayChanges = fetchData(for: loadingDate) {
            dayChangesList.append(dayChanges)
        } else {
            canLoadMore = false
        }
    }
    
    func fetchData(for date: Date) -> DayChanges? {
        
        guard 
            let timelineContents = timelineBusiness.fetchDayTimeline(for: date.getYear(), date.getMonth(), date.getDay()),
            timelineContents.count > 0
        else { return nil }
        
        var timelines = [Timeline]()
        for timelineContent in timelineContents {
            timelines.append(timelineContent.getTimeline())
        }
        
        return DayChanges(notes: timelines, date: date, metadata: "")
    }
    
}
