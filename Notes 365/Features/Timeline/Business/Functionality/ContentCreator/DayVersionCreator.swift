//
//  DayVersionCreator.swift
//  Notes 365
//
//  Created by kiran ipc on 01/12/23.
//

import Foundation

class DayVersionCreator {
    
    static let shared = DayVersionCreator()
    var business: DayVersionBusiness?
    
    private init() {
        
    }
    
    func startProviding(for business: DayVersionBusiness) {
        self.business = business
        observeNotebooksLoadedNotification()
    }
    
    func stopProviding() {
        removeObservingNotebooksLoaded()
    }
    
    func observeNotebooksLoadedNotification() {
        logger.debug("observeNotebooksLoadedNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookLoaded(_:)), name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    func removeObservingNotebooksLoaded() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    @objc func handleNotebookLoaded(_ notification: Notification) {
//        logger.debug("handleNotebookLoaded")
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let notebookConent = notification.userInfo?["notebook_content"] as? String
        else { return }
        business?.createBaseVersionIfNotExists(for: notebookId, with: notebookConent)
    }
    
}

