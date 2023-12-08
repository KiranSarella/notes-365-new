//
//  NotebookBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

class NotebookContentBusinessNew {
    
    var storage: NotebookContentStorageProvider
    
    init(storage: NotebookContentStorageProvider) {
        self.storage = storage
    }
    
    func retrieveOrInstantiateNotebookContent(for id: UUID) throws -> NotebookContentB {
        let result = try storage.fetchNotebookContent(for: id)
        if let result = result {
            defer { sendLoadedNotification(result) }
            return result
        } else {
            let result = try createNotebookContent(for: id)
            defer { sendLoadedNotification(result) }
            return result
        }
    }
    
    /// send notification, so that some one can create day base version
    private func sendLoadedNotification(_ notebookContent: NotebookContentB) {
        logger.debug("sendLoadedNotification")
        let info = [
            "notebook_id": notebookContent.notebookID,
            "notebook_content": notebookContent.content
        ] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name.notebookContentLoaded, object: nil, userInfo: info)
    }
    
    func createNotebookContent(for id: UUID) throws -> NotebookContentB {
        let notebookContent = NotebookContentB(notebookID: id)
        try notebookContent.insert(in: storage)
        return notebookContent
    }
    
    func deleteNotebookContent(for id: UUID) throws {
        try storage.deleteNotebookContent(for: id)
    }
    
    func insert(notebookContent: NotebookContentB) throws {
        try notebookContent.insert(in: storage)
    }
    
    func update(notebookContent: NotebookContentB) throws {
        try notebookContent.update(in: storage)
        do { sendUpdatedNotification(notebookContent) }
    }
    
    /// send edited notification
    /// - notebook.modifiedDate = Date()
    /// - create timeline
    private func sendUpdatedNotification(_ notebookContent: NotebookContentB) {
        // TODO: send notification after some delay - based on result.
        let info = [
            "notebook_id": notebookContent.notebookID,
            "content": notebookContent.content
        ] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name.notebookContentUpdated, object: nil, userInfo: info)
    }
}

fileprivate extension NotebookContentB {
    
    func insert(in storage: NotebookContentStorageProvider) throws {
        try storage.insert(notebookContent: self)
    }
    
    func update(in storage: NotebookContentStorageProvider) throws {
        try storage.update(notebookContent: self)
    }
}
