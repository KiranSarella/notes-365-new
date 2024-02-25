//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import UIKit
import SwiftData

public enum NotebookBusinessError: Error {
    case alreadyExists
    case invalidCharacters
    case invalidSelection
    case empty
}

class NotebooksBusiness {
    
#if DEBUG
    private let deleteExpiryLimit = 2
#else
    private let deleteExpiryLimit = 30
#endif

    var storage: NotebooksStorageProvider
    
    init(storage: NotebooksStorageProvider) {
        self.storage = storage
    }
    
    func fetchAllNotebooks() async throws -> [NotebookB] {
        logger.info("\(#function)")
        return try await storage.fetchAllNotebooks()
    }
    
    func fetchAllFolders() throws -> [NotebookB] {
        logger.info("\(#function)")
        return try storage.getAllFolders()
    }
    
    func createFolder(inside parent: NotebookB?, siblings: [NotebookB]) throws -> NotebookB {
        // create
        let newNotebookName = generateUntitledName(atLevel: siblings, prefix: "Folder")
        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
        newNotebook.parentId = parent?.id
        newNotebook.isFolder = true
        try newNotebook.insert(in: storage)
        defer { sendNotebookInserted(newNotebook) }
        return newNotebook
    }
    
    func createFile(inside parent: NotebookB?, siblings: [NotebookB]) throws -> NotebookB {
        // create
        let newNotebookName = generateUntitledName(atLevel: siblings, prefix: "Notebook")
        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
        newNotebook.parentId = parent?.id
        newNotebook.isFolder = false
        try newNotebook.insert(in: storage)
        defer { sendNotebookInserted(newNotebook) }
        return newNotebook
    }
    
    func getNotebook(id: UUID) throws -> NotebookB {
        return try storage.getNotebook(for: id)
    }
    
    func fetchItems(at parent: UUID?) throws -> [NotebookB] {
        if let parent = parent {
            return try storage.getActiveChildren(forParent: parent)
        } else {
            return try storage.getActiveTopLevelNotebooks()
        }
    }
    
    func searchItems(for searchText: String) throws -> [NotebookB] {
        try storage.searchActiveNotebooks(for: searchText)
    }
    
    func getRootNotebookOnly() throws -> NotebookB? {
        try storage.getRootNotebook()
    }
    
//    func fetchRootItems() throws -> [NotebookB] {
//        try storage.getTopLevelNotebooks()
//    }
   
    private func generateUntitledName(atLevel siblings: [NotebookB], prefix: String) -> String {
        
        var fileNameAlreadyExists: Bool {
            siblings.contains(where: { $0.name == fileName })
        }
        
        var fileName = ""
        let nameGenerator = NameGenerator(prefix: prefix)
        if siblings.isEmpty {
            fileName = nameGenerator.generateName()
        } else {
            repeat {
                fileName = nameGenerator.generateName()
            } while fileNameAlreadyExists
        }
        return fileName
    }
    
    func deleteNotebook(notebook: NotebookB) throws {
        logger.debug("\(#function)")
        notebook.deletedDate = DateTime.now()
        try notebook.update(in: storage)
        do { sendNotebookDeleted(notebook) }
    }
    
    private func isAlreadyFilenameExists(fileName: String, in siblings: [NotebookB]) -> Bool {
        return siblings.contains(where: { $0.name == fileName })
    }
    
    func rename(notebook: NotebookB, newValue: String, siblings: [NotebookB]) throws {
        
        if newValue.count == 0 {
            throw NotebookBusinessError.empty
        }
        
        if isAlreadyFilenameExists(fileName: newValue, in: siblings) {
            throw NotebookBusinessError.alreadyExists
        }
        
        notebook.name = newValue
        try notebook.update(in: storage)
        do { sendNotebookRenamed(notebook) }
    }
    
    func move(notebook: NotebookB, to destinationId: UUID?) throws {
        notebook.parentId = destinationId
        try notebook.update(in: storage)
        do { sendNotebookMoved(notebook) }
    }
    
    func fetchOnlyNotesCount() throws -> Int {
        try storage.fetchOnlyNotesCount()
    }
}

extension NotebooksBusiness {
    
    private func sendNotebookDeleted(_ notebook: NotebookB) {
        var info = [
            "notebook_id": notebook.id,
            "name": notebook.name,
            "isFolder": notebook.isFolder
        ] as [String : Any]
        if let parentId = notebook.parentId {
            info["parent_id"] = parentId
        }
        
        let notification = Notification(name: .notebookDeleted, userInfo: info)
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
        
//        NotificationCenter.default.post(name: Notification.Name.notebookDeleted, object: nil, userInfo: info)
        logger.debug("sendNotebookDeleted - \(notebook.description)")
    }
    
    private func sendNotebookRenamed(_ notebook: NotebookB) {
        var info = [
            "notebook_id": notebook.id,
            "name": notebook.name,
            "isFolder": notebook.isFolder
        ] as [String : Any]
        if let parentId = notebook.parentId {
            info["parent_id"] = parentId
        }
        NotificationCenter.default.post(name: Notification.Name.notebookRenamed, object: nil, userInfo: info)
        logger.debug("sendNotebookRenamed - \(notebook.description)")
    }
    
    private func sendNotebookInserted(_ notebook: NotebookB) {
        var info = [
            "notebook_id": notebook.id,
            "name": notebook.name,
            "isFolder": notebook.isFolder
        ] as [String : Any]
        if let parentId = notebook.parentId {
            info["parent_id"] = parentId
        }
        NotificationCenter.default.post(name: Notification.Name.notebookInserted, object: nil, userInfo: info)
        logger.debug("sendNotebookInserted - \(notebook.description)")
    }
    
    private func sendNotebookMoved(_ notebook: NotebookB) {
        var info = [
            "notebook_id": notebook.id,
            "name": notebook.name,
            "isFolder": notebook.isFolder
        ] as [String : Any]
        if let parentId = notebook.parentId {
            info["parent_id"] = parentId
        }
        NotificationCenter.default.post(name: Notification.Name.notebooksMoved, object: nil, userInfo: info)
        logger.debug("\(#function) - \(notebook.description)")
    }
    
}

extension NotebookB {
    
    func insert(in storage: NotebooksStorageProvider) throws {
        try storage.insert(notebook: self)
    }
    
    func update(in storage: NotebooksStorageProvider) throws {
        try storage.update(notebook: self)
    }
    
}

class NameGenerator {
    let prefix: String
    var sequence: Int
    
    init(prefix: String, sequence: Int = 1) {
        self.prefix = prefix
        self.sequence = sequence
    }
    
    func generateName() -> String {
        defer { sequence += 1 }
        return "\(prefix) \(sequence)"
    }
}

extension NotebooksBusiness {
    
    func getAllFilesInfo() -> [NotebookB] {
        do {
           return try storage.getAllFilesInfo()
        } catch let error {
            logger.error("\(error)")
        }
        return []
    }
}

// MARK: Deleted Notebooks
extension NotebooksBusiness {
    
    func fetchDeletedNotebooks() throws -> [NotebookB] {
        logger.info("\(#function)")
        return try storage.getDeletedNotebooks()
    }
    
    func restore(notebook: NotebookB, to destinationId: UUID?) throws {
        notebook.parentId = destinationId
        notebook.deletedDate = nil
        try notebook.update(in: storage)
        do { sendNotebookMoved(notebook) }
    }
    
    func permanentDeleteExpiredItems() async {
        logger.info("\(#function)")
        do {
            guard let expiryDate = Calendar.current.date(byAdding: .day, value: -deleteExpiryLimit, to: DateTime().date) else { return }
            
            let contentBusiness = BusinessFactory.createNotebookContentBusinessFactory()
            
            let expiredItems = try storage.fetchExpiredDeletedNotebooks(expiryDate: expiryDate)
            
            var fileIds = [UUID]()
            var folderIds = [UUID]()
            // files
            for expiryItem in expiredItems {
                if expiryItem.isFolder {
                    let (files, folders) = await NotebooksPathService.shared.getAllChildFilesAndFolders(folderId: expiryItem.id)
                    fileIds.append(contentsOf: files)
                    folderIds.append(contentsOf: folders)
                } else {
                    fileIds.append(expiryItem.id)
                }
            }
            // delete files and contents
            for fileId in fileIds {
                try contentBusiness.deleteNotebookContent(for: fileId)
                try storage.permanentDelete(notebookId: fileId)
            }
            // delete folders
            for folderId in folderIds {
                try storage.permanentDelete(notebookId: folderId)
            }
        } catch {
            logger.error("\(error)")
        }
        
    }
    
}
