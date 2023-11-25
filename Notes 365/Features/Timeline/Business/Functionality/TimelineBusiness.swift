//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftData

class TimelineBusiness {
    var todayTimelineIndex: TimelineIndex?
    var count = -5
    var today = Date()
    var storage: TimelineStorageProvider
    
    init(storage: TimelineStorageProvider) {
        self.storage = storage
    }
    
    func fetchDayTimelineNoteChanges(date: Date) throws -> [DayNotebookChange] {
        try storage.fetchDayTimelineRecords(for: date)
    }
    
    func save(dayNotebookChange: DayNotebookChange) {
        do {
            try storage.save(dayNotebookChange: dayNotebookChange)
        } catch let error {
            print(error)
        }
    }
    
}



extension TimelineBusiness {
    
    func setupTimeineCreationProcess() {
        TimelineContentCreator.shared.startProviding(for: self)
    }
    
    func stopTimelineCreationProcess() {
        TimelineContentCreator.shared.stopProviding()
    }
}
