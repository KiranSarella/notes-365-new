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
    
    func fetchNotebooks() async throws -> [Notebook] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let notebooksData = try storage.fetchNotebooks()
                let notebooks = convertToNotebooks(from: notebooksData)
                continuation.resume(returning: notebooks)
            } catch let err {
                print(err)
                continuation.resume(throwing: err)
            }
        }
    }
    
    private func convertToNotebooks(from notebooksData: [NotebookData]) -> [Notebook] {
        // prepare dict
        var dict = [UUID: NotebookData]()
        for result in notebooksData {
            dict[result.id] = result
        }
        // topLevel
        var topLevels: [NotebookData] = notebooksData.filter { $0.parent == nil }
            .sorted { $0.orderID < $1.orderID }
        topLevels.removeAll(where: { $0.isDeleted })
        // notebooks
        var notebooksList = [Notebook]()
        for topNote in topLevels {
            notebooksList.append(Notebook(topNote))
        }
        // populate childnotes
        for notebook in notebooksList {
            notebook.populateChildren(dict)
        }
        return notebooksList
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
            notebook.populateChildren(dict)
        }
        return notebooksList
    }
    
    func insert(notebook: Notebook) throws {
        try storage.insert(notebookData: notebook.generateNotebookData())
    }
    
    func update(notebook: Notebook) throws {
        
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
        notedata.orderID = orderID
        notedata.createdDate = createdDate
        notedata.modifiedDate = modifiedDate
        notedata.deletedDate = deletedDate
        return notedata
    }
    
}
