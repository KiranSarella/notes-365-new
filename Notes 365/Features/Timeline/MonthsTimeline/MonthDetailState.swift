//
//  MonthState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI
import Combine

public struct MonthTimelineThree: Identifiable {
    let day: Int
    var notes = [Timeline]()
    public let id: UUID
    let month: Int
    let year: Int
}

extension MonthTimelineThree {
    var prepareDate: Date {
        let dateStr = "\(month)/\(day)/\(year)" // 7/21/2020
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: dateStr)!
    }
}

@Observable
class MonthDetailState {
    
//    let timelineBusiness = TimelineBusiness(path: EnvironmentState.shared.basePathURL)
    
    var monthDate: MonthDate
    var currentState = CurrentState.loading
    var monthTimelineList = [DayChanges]()
    
    var generatorTask: Task<(), Never>? = nil
    
    var cancellable: Cancellable? = nil
    
    init() {
        monthDate = CalendarState.shared.monthDate
        // observe changes
        observeMonthChanges()
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
    
    func readMonthData(monthDate: MonthDate) {
        currentState = .loading
        monthTimelineList.removeAll()
        generatorTask = Task {
            var weekGenerator = WeekContentGenerator(days: Date.dates(from: monthDate.start, to: monthDate.end))
            await loadDaysData(weekGenerator: &weekGenerator)
            currentState = monthTimelineList.count > 0 ? .data : .empty
        }
    }
    
    // trying recursive
    func loadDaysData(weekGenerator: inout WeekContentGenerator) async {
        if let dayChanges = await weekGenerator.next() {
            
            monthTimelineList.append(dayChanges)
            let lines = dayChanges.metadata.components(separatedBy: "\n")
            // ??
            //            print(lines.count)
            for await timeline in DayContentGenerator(lines: lines, today: dayChanges.date) {
                //                print(timeline.fileName)
                DispatchQueue.main.async {
                    if self.generatorTask!.isCancelled { return }
                    self.monthTimelineList[self.monthTimelineList.count - 1].notes.append(timeline)
                }
                
            }
            // loaded day's note changes
            // need to initiate load next day
            //            print("AFTER FOR AWAIT - WEEK")
            await loadDaysData(weekGenerator: &weekGenerator)
            
        } else {
            currentState = .data
        }
    }
}
