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
        var t = Timeline(changesID: notebookId,
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
class TimelineDetailState {
    let timelineBusiness: TimelineInteractor
    
    var selectedDates: [Date] = []
    
    // load more
    var canLoadMore = false
    var loadingDayChanges = false
    var loadingDate = DateTime.now()
    var currentState = CurrentState.stop
    var cancellable: Cancellable? = nil
    var dayIndexs = [DayIndex]()
    var timelineIndexes = [TimelineIndex]()
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
        self.timelineIndexes.removeAll()
        self.dayIndexs.removeAll()
        currentTaskID = UUID()
        self.currentState = .stop
        self.canLoadMore = false
    }
    
//    func loadDayContent() {
//        Task {
//            do {
//                await NotebooksPathService.shared.refreshNotebooksInfo()
//                let results = try self.timelineBusiness.fetchDayTimelineNoteChanges(date: Date())
//                for result in results {
//                    let r = await result.getTimeline()
//                    timelines.append(r)
//                }
//            } catch let error {
//                print(error)
//            }
//        }
//    }
    
//    func getFirstAvailableTimelineDate() {
//        let firstEntryDate = timelineBusiness.getFirstAvailableTimelineDate()
//        logger.info("getFirstAvailableTimelineDate - \(firstEntryDate?.string(format: "yyyy-MM-dd") ?? "")")
//    }
    
   
    
    func startReloadingContent() {
//        print(#function)
//        Task {
//            clearDisplay()
//            self.currentState = .loading
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                // start fetching data
//                switch self.calendarState {
//                case .day(let dayDate):
//                    self.startFetchingDayIndex(dayDate: dayDate, reqID: self.currentTaskID)
//                case .week(let weekDate):
//                    self.startFetchingWeekIndex(weekDate: weekDate, reqID: self.currentTaskID)
//                case .month(let monthDate):
//                    self.startFetchingMonthIndex(monthDate: monthDate, reqID: self.currentTaskID)
//                }
//            }
//        }
    }
    
    
    // MARK: - Day Note Changes
    
    func tryLoadMore() {
        print(#function, loadingDayChanges)
        // have to maintain queue? - what if day content is single line?
        if loadingDayChanges {
            return
        }
        processNextDay()
    }
    
    func processFirstDay(reqID: UUID) {
//        print(#function)
//        // load first day
//        self.generatorTask = Task {
//            
//            print("timelineIndexes: before - ", timelineIndexes.count)
//            if let current = timelineIndexes.first {
//                let dayIndex = await readDayDataOnly(timelineIndex: current)
//                
//                if reqID != currentTaskID {
//                    return
//                }
//                if timelineIndexes.count == 0 {
//                    return
//                }
//                
//                timelineIndexes.removeFirst()
//                print("timelineIndexes: after - ", timelineIndexes.count)
//                DispatchQueue.main.async {
//                    self.dayIndexs.append(dayIndex)
//                    self.currentState = .data
//                }
//                // can load more
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    if self.timelineIndexes.count > 0 {
//                        self.canLoadMore = true
//                    }
//                }
//            }
//            
//        }
    }
    
    func processNextDay() {
//        print(#function)
//        if timelineIndexes.count > 0 {
//            // load first day
//            self.generatorTask = Task {
//                loadingDayChanges = true
//                let dayIndex = await readDayDataOnly(timelineIndex: timelineIndexes.removeFirst())
//                DispatchQueue.main.async {
//                    self.dayIndexs.append(dayIndex)
//                    self.loadingDayChanges = false
//                }
//            }
//        } else {
//            canLoadMore = false
//        }
    }
    
    
//    func readDayDataOnly(timelineIndex: TimelineIndex) async -> DayIndex {
//        
//        print(#function)
//        print(timelineIndex.changes)
//        let dayIndex = DayIndex(timelineIndex: timelineIndex)
//        // prepare each note change item
//        for await timelineResult in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: self.timelineBusiness) where !Task.isCancelled {
//            if Task.isCancelled { break }
//            
////            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            
////            print("timelineResut: ", timelineResult?.fileName)
////            print(self.generatorTask?.isCancelled)
////            print(Task.isCancelled)
//            if let timelineResult = timelineResult {
//                dayIndex.timelines.append(timelineResult)
////                DispatchQueue.main.async {
////                    dayIndex.timelines.append(timelineResult)
////                }
//            }
//        }
//        // after processing all note changes in a day, return all data
////        continuation.resume(returning: dayIndex)
//        
//        print("self.generatorTask = nil")
////                self.generatorTask = nil
//        return dayIndex
//    }
    
//    func readDayDataOnly(timelineIndex: TimelineIndex) async -> DayIndex {
//        await withCheckedContinuation { continuation in
//            print(#function)
//            print(timelineIndex.changes)
//            let dayIndex = DayIndex(timelineIndex: timelineIndex)
//            self.generatorTask = Task.detached {
//                // prepare each note change item
//                for await timelineResult in DayContentGenerator(lines: timelineIndex.changes, timelineBusiness: self.timelineBusiness) where !Task.isCancelled {
//                    if Task.isCancelled { return }
////                    print("timelineResut: ", timelineResult?.fileName)
////                    print(self.generatorTask?.isCancelled)
////                    print(Task.isCancelled)
//                    if let timelineResult = timelineResult {
//                        DispatchQueue.main.async {
//                            dayIndex.timelines.append(timelineResult)
//                        }
//                    }
//                }
//                // after processing all note changes in a day, return all data
//                continuation.resume(returning: dayIndex)
//                print("self.generatorTask = nil")
////                self.generatorTask = nil
//            }
//        }
//    }
    
    // MARK: - Discard Note Changes
    func removeTimelineChanges(_ timeline: Timeline) {
        // remove from UI
        dayIndexs.first?.timelines.removeAll { item in
            item.id == timeline.id
        }

        var timelineIndexId: UUID?
        
        if dayIndexs.first?.timelines.count == 0 {
            // delete timelineindex also
            timelineIndexId = dayIndexs.first?.id
            
            dayIndexs.removeAll()
            currentState = .empty
        }

        // remove physical files
//        timelineBusiness.removeTimelineChanges(timeline, timelineIndexId)
    }
    
}
