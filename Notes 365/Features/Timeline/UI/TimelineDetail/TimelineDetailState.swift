//
//  TimelineDetailState.swift
//  Notes 365
//
//  Created by kiran ipc on 03/10/23.
//

import Foundation
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
    case stop
    case loading
    case data
    case empty
    
    var message: String {
        switch self {
        case .loading:
            return "Loading.. current state"
        case .data:
            return ""
        case .empty:
            return "No notes were added/updated on the given day(s)"
        case .stop:
            return ""
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
    
    var timelineIndex: TimelineIndex
    var notes = [Timeline]()
}


extension DayNotebookChange {
    func getTimeline() async -> Timeline {
        let fileName = NotebooksPathService.shared.fileName(for: notebookId)
//        let fullPathInfo = await NotebooksPathService.shared.path(for: notebookId)
        let fullPathInfo: FullPathInfo? = FullPathInfo(id: notebookId, name: "test 1", fullPath: "empty > path")
        var t = Timeline(id: id,
                         fileUUID: notebookId,
                         fileName: fileName ?? "",
                         filePath: fullPathInfo?.fullPath ?? "")
        t.content = content
        return t
    }
    
//    var timeline: Timeline {
//        let fullPathInfo = NotebooksPathService.shared.path(for: notebookId)
//        var t = Timeline(changesID: notebookId, 
//                         fileUUID: notebookId,
//                         fileName: fullPathInfo?.name ?? "",
//                         filePath: fullPathInfo?.fullPath ?? "")
//        t.content = content
//        return t
//    }
}


@Observable
class TimelineBaseViewState {
    let timelineBusiness: TimelineInteractor
    
    var selectedDates: [Date] = []
    
    // load more
    var canLoadMore = false
    var loadingDayChanges = false
    var loadingDate = DateTime.now()
    var currentState = CurrentState.stop
    var cancellable: Cancellable? = nil
//    var timelineIndexes = [TimelineIndex]()
    var timelines = [Timeline]()
    var isFirstAppear = true
    var generatorTask: Task<(), Never>? = nil
    
    var cancellableSet = Set<AnyCancellable>()
    var currentTaskID = UUID()
    init(timelineBusiness: TimelineInteractor) {
        self.timelineBusiness = timelineBusiness
    }
    
    func clearDisplay() {
        print(#function)
        generatorTask?.cancel()
        currentTaskID = UUID()
        self.currentState = .stop
        self.canLoadMore = false
    }
    
}
