//
//  NotebooksStorageGateway.swift
//  Notes 365
//
//  Created by kiran ipc on 14/11/23.
//

import Foundation
import SwiftData

class NotebooksStorageAdapter: NotebooksStorageProvider {
    
    let storage: NotebooksStorage
    
    init(modelContext: ModelContext) {
        storage = NotebooksStorage(modelContext: modelContext)
    }
    
    func getRootNotebook() throws -> NotebookB? {
        try storage.fetchRootNotebook()?.notebook()
    }
    
    func fetchAllNotebooks() async throws -> [NotebookB] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let notebooksData = try self.storage.fetchNotebooks()
                let notebooks = notebooksData.map { $0.notebook() }
                continuation.resume(returning: notebooks)
            } catch let err {
                print(err)
                continuation.resume(throwing: err)
            }
        }
    }
    
    func insert(notebook: NotebookB) throws {
        try storage.insert(notebookData: notebook.generateNotebookData())
    }
    
    func update(notebook: NotebookB) throws {
        try storage.update(notebookData: notebook.generateNotebookData())
    }
    
    func getNotebook(for id: UUID) throws -> NotebookB {
        let notebookData = try storage.fetchNotebook(for: id)
        return NotebookB(notebookData)
    }
    
//    func getChildren(forParent id: UUID) throws -> [NotebookB] {
//        let notebookDataChilds = try storage.fetchChildren(forParent: id)
//        return notebookDataChilds.map { NotebookB($0) }
//    }
    
    
    func getActiveTopLevelNotebooks() throws -> [NotebookB] {
        let topLevelNotebooksData = try storage.fetchActiveTopLevelNotebooks()
        return topLevelNotebooksData.map { NotebookB($0) }
    }
    
    
    func getActiveChildren(forParent id: UUID) throws -> [NotebookB] {
        let notebookDataChilds = try storage.fetchActiveChildren(forParent: id)
        return notebookDataChilds.map { NotebookB($0) }
    }
    
    func getAllFilesInfo() throws -> [NotebookB] {
        return try storage.getAllFilesInfo().map { NotebookB($0) }
    }
    
}


extension NotebookB {
    
    func generateNotebookData() -> NotebookData {
        let notedata = NotebookData(id: id, name: name)
        notedata.parent = parentId
        notedata.isFolder = isFolder
        notedata.createdDate = createdDate
        notedata.modifiedDate = modifiedDate
        notedata.deletedDate = deletedDate
        return notedata
    }
    
}

extension NotebookData {
    func notebook() -> NotebookB {
        NotebookB(self)
    }
}
