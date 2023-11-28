//
//  DayNotebookChangeData.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation
import SwiftData

@Model
class DayNotebookChangeData {
//    var id: String {
//        "\(year)-\(month)-\(day)-\(notebookId)"
//    }
    var id: String = UUID().uuidString
    var notebookId: UUID = UUID()
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var updatedTime: Date = DateTime.now()
    var content: String = ""
    
    init(notebookId: UUID, year: Int, month: Int, day: Int) {
        self.id = "\(year)-\(month)-\(day)-\(notebookId)"
        self.notebookId = notebookId
        self.year = year
        self.month = month
        self.day = day
    }
}

extension DayNotebookChangeData: CustomStringConvertible {
    var description: String {
        id + "\n" + content
    }
}
