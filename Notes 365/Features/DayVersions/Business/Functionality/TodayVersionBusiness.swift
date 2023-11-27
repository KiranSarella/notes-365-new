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
        observeNotebooksLoadedNotification()
    }
    
    func observeNotebooksLoadedNotification() {
        logger.info("observeNotebooksLoadedNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookLoaded(_:)), name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    func removeObservingNotebooksLoaded() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    @objc func handleNotebookLoaded(_ notification: Notification) {
        logger.info("handleNotebookLoaded")
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let notebookConent = notification.userInfo?["notebook_content"] as? String
        else { return }
        createBaseVersionIfNotExists(for: notebookId, with: notebookConent)
    }
    
    func cleanBaseVersionIfNeeded() {
        let date = Date.yesterday
        do {
            try storage.deleteAllVersions(belowDate: date)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func createBaseVersionIfNotExists(for notebookId: UUID, with content: String) {
        logger.info("createBaseVersionIfNotExists - \(notebookId), \(content)")
        if isBaseVersionExists(notebookId: notebookId) {
            logger.info("isBaseVersionExists: true")
            return
        }
        let todayVersion = TodayVersion(notebookID: notebookId, content: content)
        do {
            try storage.create(todayVersion: todayVersion)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func isBaseVersionExists(notebookId: UUID) -> Bool {
        do {
            return try storage.isBaseVersionExists(for: notebookId)
        } catch let err {
            logger.error("\(err)")
        }
        return false
    }
    
    func getTodayVersion(for notebookId: UUID) -> String? {
        logger.info("getTodayVersion - \(notebookId)")
        do {
            return try storage.getTodayVersion(for: notebookId)
        } catch let err {
            logger.error("\(err)")
        }
        return nil
    }

    func removeDayVersion(for notebookId: UUID) {
        logger.info("removeDayVersion - \(notebookId)")
        do {
            try storage.removeDayVersion(for: notebookId)
        } catch let error {
            print(error)
        }
    }
    
}

