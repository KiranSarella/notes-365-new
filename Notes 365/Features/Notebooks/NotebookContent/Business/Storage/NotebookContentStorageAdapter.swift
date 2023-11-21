//
//  NotebookContentStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import Foundation
import SwiftData

class NotebookContentStorageAdapter: NotebookContentStorageProvider {
    
    let storage: NotebookContentStorage
    
    init(modelContext: ModelContext) {
        storage = NotebookContentStorage(modelContext: modelContext)
    }
    
    func fetchNotebookContent(for id: UUID) throws -> NotebookContentB? {
        let notebookContentData = try storage.fetchNotebookContent(for: id)
        return notebookContentData?.notebookContent()
    }
    
    func deleteNotebookContent(for id: UUID) throws {
        try storage.deleteNotebookContent(for: id)
    }
    
    func insert(notebookContent: NotebookContentB) throws {
        try storage.insert(notebookContent: notebookContent.notebookContentData())
    }
    
    func update(notebookContent: NotebookContentB) throws {
        try storage.update(notebookContent: notebookContent.notebookContentData())
    }
}

extension NotebookContentData {
    
    func notebookContent() -> NotebookContentB {
        NotebookContentB(notebookID: notebookID, content: content)
    }
}

extension NotebookContentB {
    
    func notebookContentData() -> NotebookContentData {
        NotebookContentData(notebookID: notebookID, content: content)
    }
}
