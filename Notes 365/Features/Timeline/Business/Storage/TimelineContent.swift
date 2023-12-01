//
//  TimelineContent.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation
import SwiftData

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
    var modifiedDate = DateTime.now()
    
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
    
//    func getTimeline() -> Timeline {
//        return Timeline(changeID: id, fileUUID: notebookID, fileName: filename, filePath: getAbsolutePath(), content: content)
//    }
//    
   
}
