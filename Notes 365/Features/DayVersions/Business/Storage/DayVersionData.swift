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
        self.id = Self.createID(for: notebookID, date: date)
        self.notebookID = notebookID
        self.content = content
    }
    
    static func createID(for notebookID: UUID, date: Date) -> String {
        "\(date.string(format: "yyyy-MM-dd"))-\(notebookID)"
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

extension DayVersionData: Equatable {
    static func == (lhs: DayVersionData, rhs: DayVersionData) -> Bool {
        lhs.id == rhs.id
    }
}
