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
            return "(empty)"
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

class DayDetailState: ObservableObject {
    
    let timelineBusiness = TimelineBusiness.shared
    
    @Published var dayDate: DayDate = DayDate(date: CalendarState.shared.selectedDate)
    @Published var currentState = CurrentState.loading
    @Published var timelineList = [TimelineThree]()
    @Published var searchInput: String = ""
    @Published var theme: MarkdownTheme = ThemeManager.shared.getSelectedTheme()
    @Published var generatorTask: Task<(), Never>?
    
    @Published var speechState = SpeechState.stopped
    
    let speechHelper = SpeechHelper()
    
//    @Published var dayDateTest: DayDate
    
    var cancellable: Cancellable!
    
    init() {
        
        cancellable = CalendarState.shared.$dayDate
            .receive(on: DispatchQueue.main)
            .sink { newDayDate in
            self.dayDate = newDayDate
        }
//        cancellable =
//        CalendarState.shared.$dayDate.assign(to: &dayDateTest)
    }
    
    deinit {
        cancellable.cancel()
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
