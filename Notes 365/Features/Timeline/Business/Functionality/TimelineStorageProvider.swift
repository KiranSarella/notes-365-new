//
//  TimelineStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation

protocol TimelineStorageProvider {
    func fetchDayTimelineRecords(for date: Date) throws -> [DayNotebookChange]
    func save(dayNotebookChange: DayNotebookChange) throws
    func getFirstAvailableTimelineDate() throws -> Date?
    func delete(dayNotebookChange: DayNotebookChange) throws
}
