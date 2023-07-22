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

@Observable
class DayDetailState {
    
    let timelineBusiness = TimelineBusiness(path: EnvironmentState.shared.basePathURL)
    
    var dayDate: DayDate = DayDate(date: CalendarState.shared.selectedDate)
    var currentState = CurrentState.loading
    var timelineList = [Timeline]()
    var searchInput: String = ""
    var theme: MarkdownTheme = ThemeState.shared.theme
    var generatorTask: Task<(), Never>? = nil
    
    var speechState = SpeechState.stopped
    
    let speechHelper = SpeechHelper()
    
//    @Published var dayDateTest: DayDate
    
    var cancellable: Cancellable? = nil
    var cancellableTheme: Cancellable? = nil
    
    init() {
        
        observeCalenderChanges()
        observeThemeChanges()
    }
    
    func observeCalenderChanges() {
        cancellable = CalendarState.shared.$dayDate
            .receive(on: DispatchQueue.main)
            .sink { newDayDate in
                self.dayDate = newDayDate
            }
    }
    
    func observeThemeChanges() {
        cancellableTheme =  ThemeState.shared.themePub
            .receive(on: DispatchQueue.main)
            .sink { newTheme in
                self.theme = newTheme
            }
    }
    
    deinit {
        cancellable?.cancel()
        cancellableTheme?.cancel()
    }
    
//    func updateNewDateDate(newDayDate: DayDate) {
//        self.dayDate = newDayDate
//    }
    
    func readDayData(dayDate: DayDate) {
        
        currentState = .loading
        // prepare folder path
        // read metadata (here we are not checking if day folder exists or not, so checking metadata file existance)
        // async read file content for each metadata's line
        // and async construct attributedstring
        // append to SwiftUI state.
        
        timelineList.removeAll()
        
        guard let metadata = timelineBusiness.readDayMetaData(dayDate: dayDate) else {
            currentState = .empty
            return
        }
        
        let lines = metadata.components(separatedBy: "\n")
        // remove empty lines
        // ?
        
        generatorTask = Task {
            
            for await timeline in DayContentGenerator(lines: lines, today: dayDate.date, theme: theme) {
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
    
}
