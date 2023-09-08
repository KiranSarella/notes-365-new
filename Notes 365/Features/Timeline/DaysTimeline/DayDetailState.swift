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

class DayDetailState: ObservableObject {
    
    let timelineBusiness = TimelineBusiness(path: EnvironmentState.shared.basePathURL)
    
    @Published var dayDate: DayDate = DayDate(date: CalendarState.shared.selectedDate)
    @Published var currentState = CurrentState.loading
    @Published var timelineList = [Timeline]()
    @Published var searchInput: String = ""
    @Published var generatorTask: Task<(), Never>?
    
    @Published var dayNumberText: String = ""
    @Published var showDayNumberFromDOB = true
    
    @Published var speechState = SpeechState.stopped
    
    let speechHelper = SpeechHelper()
    
    var cancellable: Cancellable!
    var cancellableSet = Set<AnyCancellable>()
    
    var canDelete: Bool {
        dayDate.date.isSameDayAs(Date())
    }
    
    init() {
        
        observeCalenderChanges()
        observeDayNumberOptionChanges()
    }
    
    func observeCalenderChanges() {
        cancellable = CalendarState.shared.$dayDate
            .receive(on: DispatchQueue.main)
            .sink { newDayDate in
                self.dayDate = newDayDate
            }
    }
    
    deinit {
        cancellable.cancel()
    }
    
//    func updateNewDateDate(newDayDate: DayDate) {
//        self.dayDate = newDayDate
//    }
    
    
    func observeDayNumberOptionChanges() {
        $showDayNumberFromDOB.sink { isOn in
            if isOn {
                self.updateDayNumberTextWithDOB()
            } else {
                self.updateDayNumberTextWithYear()
            }
        }.store(in: &cancellableSet)
    }
    
    func updateDayNumberText() {
        self.updateDayNumberTextWithYear()
        
//        if self.showDayNumberFromDOB {
//            self.updateDayNumberTextWithDOB()
//        } else {
//            self.updateDayNumberTextWithYear()
//        }
    }
    
    func updateDayNumberTextWithDOB() {
        let dob = "1989-07-21 00:00:00".toUTCDate()!
        let count = dayDate.date.getDayNumberFromStart(dob)
        dayNumberText = "DAY \(count)"
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
        
        guard let metadata = timelineBusiness.readDayMetaData(dayDate: dayDate) else {
            currentState = .empty
            return
        }
        
        let lines = metadata.components(separatedBy: "\n")
        // remove empty lines
        // ?
        
        generatorTask = Task {
            
            for await timeline in DayContentGenerator(lines: lines, today: dayDate.date) {
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
    
    func removeChanges(timeline: Timeline) {
        // remove timeline file
        timelineBusiness.removeContent(today: Date(), fileName: timeline.fileUUID.uuidString)
        // update metadata file
        
        // remove base version
        
    }
    
}
