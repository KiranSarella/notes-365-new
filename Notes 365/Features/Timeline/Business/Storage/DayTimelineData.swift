//
//  DayTimeline.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation
import SwiftData

@Model
class DayTimelineData {
    var id: String {
        "\(year)-\(month)-\(day)"
    }
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var dayNotebookChanges = [String]()
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}
