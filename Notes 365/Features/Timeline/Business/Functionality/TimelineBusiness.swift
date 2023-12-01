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
    var today = DateTime.now()
    var storage: TimelineStorageProvider
    let dayVersionBusiness = BusinessFactory.dayVersionInteractor()
    
    init(storage: TimelineStorageProvider) {
        self.storage = storage
    }
    
    func fetchDayTimelineNoteChanges(date: Date) throws -> [DayNotebookChange] {
        logger.info("\(#function)")
        return try storage.fetchDayTimelineRecords(for: date)
    }
    
    func save(dayNotebookChange: DayNotebookChange) {
        logger.info("\(#function)")
        do {
            try storage.save(dayNotebookChange: dayNotebookChange)
        } catch let error {
            print(error)
        }
    }
    
    func getFirstAvailableTimelineDate() -> Date? {
        logger.info("\(#function)")
        do {
            return try storage.getFirstAvailableTimelineDate()
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func clean(dayNotebookChange: DayNotebookChange) {
        logger.info("\(#function)")
        do {
            try storage.delete(dayNotebookChangeId: dayNotebookChange.id)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func discard(changeId: String, date: Date, fileId: UUID) throws {
        logger.info("\(#function)")
        try storage.delete(dayNotebookChangeId: changeId)
        if date.isSameDayAs(DateTime.now()) {
            dayVersionBusiness.removeDayVersion(for: fileId)
        }
    }
}



extension TimelineBusiness {
    
    func setupTimeineCreationProcess() {
        logger.info("\(#function)")
        TimelineContentCreator.shared.startProviding(for: self)
    }
    
    func stopTimelineCreationProcess() {
        logger.info("\(#function)")
        TimelineContentCreator.shared.stopProviding()
    }
}
