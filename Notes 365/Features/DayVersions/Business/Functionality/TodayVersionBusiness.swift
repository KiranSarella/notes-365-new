//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation
import SwiftData

class TodayVersionBusiness {
    var storage: TodayVersionStorageProvider
    
    init(storage: TodayVersionStorageProvider) {
        self.storage = storage
    }
    
    func cleanOlderDayVersions() {
        logger.info("\(#function)")
        let yesterday = DateTime.now().dayBefore
        do {
            try storage.deleteAllVersions(belowDate: yesterday)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func createBaseVersionIfNotExists(for notebookId: UUID, with content: String) {
        logger.debug("createBaseVersionIfNotExists - \(notebookId), \(content)")
        if isBaseVersionExists(notebookId: notebookId) {
            logger.debug("isBaseVersionExists: true")
            return
        }
        let todayVersion = DayVersionData(notebookID: notebookId, content: content)
        do {
//            logger.debug("\(todayVersion)")
            try storage.create(todayVersion: todayVersion)
            logger.debug("new base version created")
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func isBaseVersionExists(notebookId: UUID) -> Bool {
        do {
            let todayVersionId = DayVersionData(notebookID: notebookId).id
            return try storage.isBaseVersionExists(for: todayVersionId)
        } catch let err {
            logger.error("\(err)")
        }
        return false
    }
    
    func getTodayVersion(for notebookId: UUID) -> String? {
        logger.debug("getTodayVersion - \(notebookId)")
        do {
            let todayVersionId = DayVersionData(notebookID: notebookId).id
            return try storage.getTodayVersion(for: todayVersionId)
        } catch let err {
            logger.error("\(err)")
        }
        return nil
    }

    func removeDayVersion(for notebookId: UUID) {
        logger.debug("removeDayVersion - \(notebookId)")
        do {
            let todayVersionId = DayVersionData(notebookID: notebookId).id
            try storage.removeDayVersion(for: todayVersionId)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
}


extension TodayVersionBusiness {
    
    func setupDayVersionCreationProcess() {
        logger.info("\(#function)")
        DayVersionCreator.shared.startProviding(for: self)
        cleanOlderDayVersions()
    }
    
    func stopDayVersionCreationProcess() {
        logger.info("\(#function)")
        DayVersionCreator.shared.stopProviding()
    }
}
