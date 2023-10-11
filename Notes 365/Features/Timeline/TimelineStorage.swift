//
//  TimelineContent.swift
//  Notes 365
//
//  Created by kiran ipc on 26/09/23.
//

import Foundation
import SwiftData


/*
 each timeline index refers to one day.
 */
@Model
class TimelineIndex {
    var id: UUID = UUID()

    var changes = [UUID]()
    
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    //    var dateString: String = Date().string(withFormat: "yyyy-MM-dd")
    var dateString: String {
        "\(year)-\(month)-\(day)"
    }
    
    
//    @Transient
//    var timelineContents: [TimelineContent]?
    
//    @Transient
    var date: Date {
        dateString.toLocalDate(withFormat: "yyyy-MM-dd")!
    }
//    
//    @Transient
//    var isDataLoaded = false
//    @Transient
//    var dayChanges: DayChanges!
    
    init() {
        
    }
    
//    func loadTimelineContent(_ business: TimelineBusiness) {
//        // fetch all timeline contents in a single day
//        var timelineContents = [TimelineContent]()
//        
//        for id in changes {
//            if let timelineContent = business.fetchTimelineContent(for: id) {
//                timelineContents.append(timelineContent)
//            }
//        }
//        // prepare to display
//        prepareDayChanges(timelineContents: timelineContents)
//    }
//    
//    func prepareDayChanges(timelineContents: [TimelineContent]) {
//        
////        guard let timelineContents = timelineContents else { return }
//        
//        DispatchQueue.main.async {
//            var timelines = [Timeline]()
//            for timelineContent in timelineContents {
//                timelines.append(timelineContent.getTimeline())
//            }
//        
//            self.dayChanges = DayChanges(notes: timelines, date: self.date, metadata: "")
//            // Delay the task by 1 second:
////            try await Task.sleep(nanoseconds: 2_000_000_000)
//            self.isDataLoaded = true
//        }
//         
//    }
}

@Model
class TimelineContent {
    var id: UUID = UUID()
    
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    
    var content = ""
    var notebookID: UUID = UUID()
    var filename = ""
    var path = [String]()
    var modifiedDate = Date()
    
    func getAbsolutePath() -> String {
        // https://www.compart.com/en/unicode/U+203A
        return path.joined(separator: "  \u{203A}   ")
    }
    
    var date: Date {
        let dateStr = "\(day)/\(month)/\(year)"
        return Date.fromString(dateStr: dateStr)!
    }
    
    init() {
        
    }
    
    func getTimeline() -> Timeline {
        return Timeline(fileUUID: notebookID, fileName: filename, filePath: getAbsolutePath(), content: content)
    }
    
   
}
