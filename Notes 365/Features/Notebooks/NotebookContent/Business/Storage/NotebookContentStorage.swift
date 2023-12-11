//
//  NotebookContentStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import Foundation
import SwiftData

public enum NotebookContentStorageError: Error {
    case noContent
}

class NotebookContentStorage {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func isNotebookContentExits(for id: UUID) throws -> Bool {
        let contentPredicate = #Predicate<NotebookContentData> {
            $0.notebookID == id
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        let result = try modelContext.fetchCount(descriptor)
        return result > 0
    }
    
    func fetchNotebookContent(for id: UUID) throws -> NotebookContentData? {
        let contentPredicate = #Predicate<NotebookContentData> {
            $0.notebookID == id
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    func deleteNotebookContent(for id: UUID) throws {
        let contentPredicate = #Predicate<NotebookContentData> {
            $0.notebookID == id
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        try modelContext.delete(model: NotebookContentData.self, where: contentPredicate)
    }
    
    func insert(notebookContent: NotebookContentData) throws {
        modelContext.insert(notebookContent)
        try modelContext.save()
    }
    
    func update(notebookContent: NotebookContentData) throws {
        try notebookContent.modelContext?.save()
    }
    
    func deleteAllRecords() throws {
        try modelContext.delete(model: NotebookContentData.self)
    }
}
