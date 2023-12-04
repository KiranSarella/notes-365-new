//
//  DayNotebookChangeData.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation
import SwiftData

struct TimelineB: Identifiable {
    var id: String {
        "\(year)-\(month)-\(day)-\(notebookId)"
    }
    var notebookId: UUID
    var year: Int
    var month: Int
    var day: Int
    var updatedTime: Date = DateTime.now()
    var content: String = ""
    
    init(notebookId: UUID, year: Int, month: Int, day: Int) {
        self.notebookId = notebookId
        self.year = year
        self.month = month
        self.day = day
    }
    
    init(notebookId: UUID, date: Date) {
        self.notebookId = notebookId
        self.year = date.getYear()
        self.month = date.getMonth()
        self.day = date.getDay()
    }
}
