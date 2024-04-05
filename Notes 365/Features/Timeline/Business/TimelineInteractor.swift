//
//  TimelineInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation

protocol TimelineInteractor {
    func fetchDayTimelineNoteChanges(date: Date) throws -> [TimelineB]
    func fetchDayTimelineNoteChanges(id: String) throws -> TimelineB?
    func setupTimeineCreationProcess()
    func stopTimelineCreationProcess()
    func getFirstAvailableTimelineDate() -> Date?
    func discard(changeId: String, date: Date, fileId: UUID) throws
    func updateTimelineContent(_ timeline: TimelineB) throws
}

extension TimelineBusiness: TimelineInteractor {
    
}
