//
//  TodayVersion.swift
//  Notes 365
//
//  Created by kiran ipc on 26/09/23.
//

import Foundation
import SwiftData

@Model
class DayVersionData {
    var id: String = UUID().uuidString
    var notebookID: UUID = UUID()
    var content: String = ""
    var date: Date = DateTime.now()
    
    init(notebookID: UUID, content: String = "") {
        self.id = "\(date.string(format: "yyyy-MM-dd"))-\(notebookID)"
        self.notebookID = notebookID
        self.content = content
    }
}

extension DayVersionData: CustomStringConvertible {
    var description: String {
        var str = ""
        str.append("\(id)\n")
        str.append("\(content)\n")
        return str
    }
}
