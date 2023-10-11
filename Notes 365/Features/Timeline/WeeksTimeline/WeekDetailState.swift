//
//  WeekDetailState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI
import Combine


@Observable
class WeekDetailState {
    
    var weekDate: WeekDate = WeekDate(date: Date())
    var currentState = CurrentState.loading
    var weekTimelineList = [DayChanges]()
    
    var generatorTask: Task<(), Never>? = nil
    
    var cancellable: Cancellable? = nil
//    var cancellableTheme: Cancellable!
    
    
    
    init() {
        
        // observe changes
        observeCalenderChanges()
//        observeThemeChanges()
    }
    
    func observeCalenderChanges() {
//        cancellable = CalendarState.shared.$weekDate
//            .receive(on: DispatchQueue.main)
//            .sink { newWeekDate in
//                self.weekDate = newWeekDate
//            }
    }
    
//    func observeThemeChanges() {
//        cancellableTheme = ThemeState.shared.$theme
//            .receive(on: DispatchQueue.main)
//            .sink { newTheme in
//                self.theme = newTheme!
//            }
//    }
    
    deinit {
        cancellable?.cancel()
    }
    
    
    
}
