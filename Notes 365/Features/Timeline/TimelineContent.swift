//
//  TimelineContent.swift
//  Notes 365
//
//  Created by kiran ipc on 26/09/23.
//

import Foundation
import SwiftData

@Model
class TimelineContent {
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
    
    init() {
        
    }
    
    func getTimeline() -> Timeline {
        return Timeline(fileUUID: notebookID, fileName: filename, filePath: getAbsolutePath(), content: content)
    }
}
