//
//  CloudKitSync.swift
//  Notes 365
//
//  Created by kiran ipc on 23/12/23.
//

import Foundation
import SwiftData
import CoreData

extension Notification.Name {
    public static let icloudSyncFinished = Notification.Name("com.notes365.icloudSyncFinished")
}

@Observable
class CloudKitSync {
    var isImportDone = false
    var cloudKitEventsObserver: NSObjectProtocol?
    
    init() {
        observeSync()
    }
    
    func observeSync() {
        cloudKitEventsObserver = NotificationCenter.default.addObserver(forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: .main) { [weak self] notification in

            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }

            let isFinished = event.endDate != nil
            
            switch event.type {
            case .setup:
                if isFinished {
                    logger.debug("setup done")
                } else {
                    logger.debug("setup started")
                }
            case .import:
                if isFinished {
                    logger.debug("import done")
                    self?.isImportDone = true
                    self?.sendCloudSyncFinishNotification()
                } else {
                    logger.debug("import started")
                    self?.isImportDone = false
                }
            case .export:
                if isFinished {
                    logger.debug("export done")
                } else {
                    logger.debug("export started")
                }
            @unknown default:
                break
            }
            
        }
    }
    
    /// send notification, so that some one can create day base version
    private func sendCloudSyncFinishNotification() {
        logger.info("\(#function)")
        NotificationCenter.default.post(name: Notification.Name.icloudSyncFinished, object: nil, userInfo: nil)
    }
}
