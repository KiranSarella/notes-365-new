//
//  TimelineStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation
import SwiftData

class TimelineStorageAdapter: TimelineStorageProvider {
    
    let storage: TimelineStorage
    
    init(modelContext: ModelContext) {
        self.storage = TimelineStorage(modelContext: modelContext)
    }
    
    func fetchDayTimelineRecords(for date: Date) throws -> [DayNotebookChange] {
        try storage.fetchDayTimelineRecords(for: date).map { $0.dayNotebookChange() }
    }
    
    func save(dayNotebookChange: DayNotebookChange) throws {
        try storage.save(dayNotebookChange: dayNotebookChange.dayNotebookData())
    }
    
}

extension DayNotebookChangeData {
    func dayNotebookChange() -> DayNotebookChange {
        var dayNotebookChange = DayNotebookChange(notebookId: notebookId, year: year, month: month, day: day)
        dayNotebookChange.updatedTime = updatedTime
        dayNotebookChange.content = content
        return dayNotebookChange
    }
    
    func sync(newValue: DayNotebookChangeData) {
        self.content = newValue.content
        self.updatedTime = newValue.updatedTime
    }
}

extension DayNotebookChange {
    func dayNotebookData() -> DayNotebookChangeData {
        let data = DayNotebookChangeData(notebookId: notebookId, year: year, month: month, day: day)
        data.content = content
        data.updatedTime = updatedTime
        return data
    }
}
