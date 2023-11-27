//
//  TimelineInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation

protocol TimelineInteractor {
    func fetchDayTimelineNoteChanges(date: Date) throws -> [DayNotebookChange]
    func setupTimeineCreationProcess()
    func stopTimelineCreationProcess()
    func getFirstAvailableTimelineDate() -> Date?
}

extension TimelineBusiness: TimelineInteractor {
    
}
