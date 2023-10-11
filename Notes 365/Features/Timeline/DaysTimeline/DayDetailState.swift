//
//  DayDetailState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI
import Combine


public class Page: Identifiable {
    public var id = UUID()
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var isEditing:Bool = true
    var content: String
    
    init(content: String = "") {
        self.content = content
    }
}


class DayContent {
    
    var date: Date
    
    var pages: [Page]
    
    init(date: Date, pages: [Page] = [Page]()) {
        self.date = date
        self.pages = pages
    }
}


@Observable
class DayDetailState {
    
    let timelineBusiness: TimelineBusiness
    
    var dayDate: DayDate = DayDate(date: Date())
    var currentState = CurrentState.loading
    var timelineList = [Timeline]()
    var searchInput: String = ""
    var generatorTask: Task<(), Never>? = nil
    
    var dayNumberText: String = ""
    var showDayNumberFromDOB = true
    
    var speechState = SpeechState.stopped
    
    let speechHelper = SpeechHelper()
    
    var cancellable: Cancellable? = nil
    var cancellableSet = Set<AnyCancellable>()
    
    var canDelete: Bool {
        dayDate.date.isSameDayAs(Date())
    }
    
    init(timelineBusiness: TimelineBusiness) {
        self.timelineBusiness = timelineBusiness
        
        observeCalenderChanges()
//        observeDayNumberOptionChanges()
    }
    
    func observeCalenderChanges() {
        
//        cancellable = CalendarState.shared.$dayDate
//            .receive(on: DispatchQueue.main)
//            .sink { newDayDate in
//                self.dayDate = newDayDate
//            }
    }
    
    deinit {
        cancellable?.cancel()
    }

    
    func updateDayNumberText() {
        self.updateDayNumberTextWithYear()
        
//        if self.showDayNumberFromDOB {
//            self.updateDayNumberTextWithDOB()
//        } else {
//            self.updateDayNumberTextWithYear()
//        }
    }
    
    func updateDayNumberTextWithYear() {
        let count = dayDate.date.getDayNumber()
        dayNumberText = "DAY \(count)"
    }
    
    func readDayData(dayDate: DayDate) {
//        updateDayNumberText()
        
        currentState = .loading
        // prepare folder path
        // read metadata (here we are not checking if day folder exists or not, so checking metadata file existance)
        // async read file content for each metadata's line
        // and async construct attributedstring
        // append to SwiftUI state.
        
        timelineList.removeAll()
        
        
        guard let timelineIndex = timelineBusiness.fetchDayTimelineIndex(year: dayDate.date.getYear(), month: dayDate.date.getMonth(), day: dayDate.date.getDay()) else {
            currentState = .empty
            return
        }
        
        
        // remove empty lines
        // ?
        
        generatorTask = Task {
            
            for await timeline in DayContentGenerator(lines: timelineIndex.changes, today: dayDate.date, timelineBusiness: timelineBusiness) {
                if Task.isCancelled == true { return }
                DispatchQueue.main.async {
                    self.timelineList.append(timeline)
                }
            }
            
            DispatchQueue.main.async {
                self.currentState = .data
            }
        }
    }
    
    func removeTimelineChanges(_ timeline: Timeline) {
        // remove from UI
        timelineList.removeAll { item in
            item.id == timeline.id
        }
        
        if timelineList.count == 0 {
            currentState = .empty
        }
        
        // remove physical files
        timelineBusiness.removeTimelineChanges(timeline)
    }
}
