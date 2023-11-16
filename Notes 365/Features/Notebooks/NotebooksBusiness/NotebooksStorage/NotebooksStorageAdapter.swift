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
    
    func getRootNotebook() throws -> Notebook? {
        try storage.fetchRootNotebook()?.notebook()
    }
    
    func fetchNotebooksHierarchy() async throws -> Notebook? {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let notebooksData = try storage.fetchNotebooks()
                let notebooksHierarchy = formNotebooksHierarchy(from: notebooksData)
                continuation.resume(returning: notebooksHierarchy)
            } catch let err {
                print(err)
                continuation.resume(throwing: err)
            }
        }
    }
    
    private func formNotebooksHierarchy(from notebooksData: [NotebookData]) -> Notebook? {
        // prepare dict
        var dict = [UUID: NotebookData]()
        for result in notebooksData {
            dict[result.id] = result
        }
        guard let rootNotebookData = notebooksData.first(where: { $0.parent == nil }) else { return nil }
        let rootNotebook = rootNotebookData.notebook()
        rootNotebook.populateChildren(from: dict)
        return rootNotebook
    }
    
    
    func fetchDeletedNotebooks() async throws -> [Notebook] {
        try await withCheckedThrowingContinuation({ continuation in
            do {
                let notebooksData: [NotebookData] = try storage.fetchNotebooks()
                let deletedNotebooks = prepareDeletedNotebooksOnly(from: notebooksData)
                continuation.resume(returning: deletedNotebooks)
            } catch let err {
                print(err)
                continuation.resume(throwing: err)
            }
        })
    }
    
    private func prepareDeletedNotebooksOnly(from notebooksData: [NotebookData]) -> [Notebook] {
        // prepare dict
        var dict = [UUID: NotebookData]()
        for result in notebooksData {
            dict[result.id] = result
        }
        // deleted topLevel
        var topLevels = notebooksData.filter { $0.isDeleted == true }
        topLevels.sort { $0.deletedDate! > $1.deletedDate! }
        // notebooks
        var notebooksList = [Notebook]()
        for topNote in topLevels {
            notebooksList.append(Notebook(topNote))
        }
        // populate childnotes
        for notebook in notebooksList {
            notebook.populateChildren(from: dict)
        }
        return notebooksList
    }
    
    func insert(notebook: Notebook) throws {
        try storage.insert(notebookData: notebook.generateNotebookData())
    }
    
    func update(notebook: Notebook) throws {
        try storage.update(notebookData: notebook.generateNotebookData())
    }
    
    func getNotebook(for id: UUID) throws -> Notebook {
        let notebookData = try storage.fetchNotebook(for: id)
        return Notebook(notebookData)
    }
    
    func getTopLevelNotebooks() throws -> [Notebook] {
        let topLevelNotebooksData = try storage.fetchTopLevelNotebooks()
        return topLevelNotebooksData.map { Notebook($0) }
    }
    
    func getChildren(forParent id: UUID) throws -> [Notebook] {
        let notebookDataChilds = try storage.fetchChildren(forParent: id)
        return notebookDataChilds.map { Notebook($0) }
    }
    
    
}


extension Notebook {
    
    func generateNotebookData() -> NotebookData {
        let notedata = NotebookData(id: id, name: name)
        notedata.parent = parentId
        notedata.children = childrenIds
//        notedata.orderID = orderID
        notedata.createdDate = createdDate
        notedata.modifiedDate = modifiedDate
        notedata.deletedDate = deletedDate
        return notedata
    }
    
}

extension NotebookData {
    func notebook() -> Notebook {
        Notebook(self)
    }
}
