//
//  WeekDetailState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI
import Combine

public struct Week: Hashable {
    let weekNumber: Int
    let weekDays: [Date]
    
    func isCurrentWeek() -> Bool {
        // check same year
        // check same month
        // today should be in between weekdates
        let today = Date()
        
        let start = self.weekDays.first!
        let end = self.weekDays.last!
        
        if start.getYear() == today.getYear() &&
            start.getMonth() == today.getMonth() {
            // today should be in between that week dates
            if today >= start && today <= end {
                return true
            }
        }
        
        return false
    }
    
}

public struct DayChanges: Identifiable {
    public let id = UUID()
    
    var notes = [TimelineThree]()
    let date: Date
    let metadata: String
}

@MainActor class WeekDetailState: ObservableObject {
    
    let timelineBusiness = TimelineBusiness.shared
    
    @Published var weekDate: WeekDate
    @Published var currentState = CurrentState.loading
    @Published var weekTimelineList = [DayChanges]()
    @Published var theme: MarkdownTheme = ThemeState.shared.theme
    
    @Published var generatorTask: Task<(), Never>?
    
    var cancellable: Cancellable!
    var cancellableTheme: Cancellable!
    
    init() {
        
        weekDate = CalendarState.shared.weekDate
        // observe changes
        observeCalenderChanges()
        observeThemeChanges()
    }
    
    func observeCalenderChanges() {
        cancellable = CalendarState.shared.$weekDate
            .receive(on: DispatchQueue.main)
            .sink { newWeekDate in
                self.weekDate = newWeekDate
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
    
    func readWeekData(weekDate: WeekDate) {
        
        currentState = .loading
        weekTimelineList.removeAll()
        
        // read data from folder path
        // read metadata
        // read files content for each metadata line
        // construct list
        
        // notebook path (to show as subheading)
        if DirectoryManager.shared.fullPaths.isEmpty {
            //            let users = UsersList.shared.usersDB.retrieveObject()
            //            UsersList.shared.usersDB.users = users ?? []
            //            // prepare full paths
            //            DirectoryManager.shared.prepareFolderPaths()
        }
        
        generatorTask = Task {
            var weekGenerator = WeekContentGenerator(days: weekDate.days)
            await loadDaysData(weekGenerator: &weekGenerator)
            currentState = weekTimelineList.count > 0 ? .data : .empty
        }
    }
    
    
    // trying recursive
    func loadDaysData(weekGenerator: inout WeekContentGenerator) async {
        if let dayChanges = await weekGenerator.next() {
            
            weekTimelineList.append(dayChanges)
            let lines = dayChanges.metadata.components(separatedBy: "\n")
            // ??
            //            print(lines.count)
            for await timeline in DayContentGenerator(lines: lines, today: dayChanges.date, theme: theme) {
                //                print(timeline.fileName)
                DispatchQueue.main.async {
                    if self.generatorTask!.isCancelled { return }
                    self.weekTimelineList[self.weekTimelineList.count - 1].notes.append(timeline)
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
