//
//  WeekDetailState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI
import Combine



public struct DayChanges: Identifiable {
    public let id = UUID()
    
    var notes = [Timeline]()
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
