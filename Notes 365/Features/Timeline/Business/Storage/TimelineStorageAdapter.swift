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
    
    func fetchDayTimelineRecords(for date: Date) throws -> [TimelineB] {
        try storage.fetchDayTimelineRecords(for: date).map { $0.dayNotebookChange() }
    }
    
    func save(dayNotebookChange: TimelineB) throws {
        try storage.save(dayNotebookChange: dayNotebookChange.dayNotebookData())
    }
    
    func getFirstAvailableTimelineDate() throws -> Date? {
        try storage.getFirstAvailableTimelineDate()
    }
    
    func delete(dayNotebookChangeId: String) throws {
        try storage.delete(for: dayNotebookChangeId)
    }
    
}

extension TimelineData {
    func dayNotebookChange() -> TimelineB {
        var dayNotebookChange = TimelineB(notebookId: notebookId, year: year, month: month, day: day)
        dayNotebookChange.updatedTime = updatedTime
        dayNotebookChange.content = content
        return dayNotebookChange
    }
    
    func sync(newValue: TimelineData) {
        self.content = newValue.content
        self.updatedTime = newValue.updatedTime
    }
}

extension TimelineB {
    func dayNotebookData() -> TimelineData {
        let data = TimelineData(notebookId: notebookId, year: year, month: month, day: day)
        data.content = content
        data.updatedTime = updatedTime
        return data
    }
}
