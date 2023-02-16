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


@MainActor class MonthDetailState: ObservableObject {
    
    let timelineBusiness = TimelineBusiness.shared
    
    @Published var monthDate: MonthDate
    @Published var currentState = CurrentState.loading
    @Published var monthTimelineList = [DayChanges]()
    @Published var theme: MarkdownTheme = ThemeState.shared.theme
    
    @Published var generatorTask: Task<(), Never>?
    
    var cancellable: Cancellable!
    var cancellableTheme: Cancellable!
    
    init() {
        monthDate = CalendarState.shared.monthDate
        // observe changes
        observeMonthChanges()
        observeThemeChanges()
    }
    
    func observeMonthChanges() {
        cancellable = CalendarState.shared.$monthDate
            .receive(on: DispatchQueue.main)
            .sink { newMonthDate in
                self.monthDate = newMonthDate
            }
    }
    
    func observeThemeChanges() {
        cancellableTheme = ThemeState.shared.$theme
            .receive(on: DispatchQueue.main)
            .sink { newTheme in
                self.theme = newTheme!
            }
    }
    
    deinit {
        cancellable.cancel()
        cancellableTheme.cancel()
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
            for await timeline in DayContentGenerator(lines: lines, today: dayChanges.date, theme: theme) {
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
