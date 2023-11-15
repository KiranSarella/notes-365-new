//
//  NotebooksStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 14/11/23.
//

import Foundation
import SwiftData

public enum StorageError: Error {
    case invalidId
    case contextNotAvailable
}

class NotebooksStorage {
    
    var modelContext: ModelContext?
    
    func fetchNotebooks() throws -> [NotebookData] {
        
        guard let modelContext = modelContext else { return [] }
        
        let allListPredicate = #Predicate<NotebookData> { _ in true }
        let descriptor = FetchDescriptor(predicate: allListPredicate)
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchDeletedNotebooks() throws -> [NotebookData] {
        
        guard let modelContext = modelContext else { return [] }
        
        let allListPredicate = #Predicate<NotebookData> { _ in true }
        let descriptor = FetchDescriptor(predicate: allListPredicate)
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchNotebook(for id: UUID) throws -> NotebookData {
        guard let modelContext = modelContext else { throw StorageError.contextNotAvailable }
        let predicate = #Predicate<NotebookData> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        if let notebookData = results.first {
            return notebookData
        } else {
            throw StorageError.invalidId
        }
    }
    
    func fetchChildren(forParent id: UUID) throws -> [NotebookData] {
        guard let modelContext = modelContext else { throw StorageError.contextNotAvailable }
        let predicate = #Predicate<NotebookData> { $0.parent == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchTopLevelNotebooks() throws -> [NotebookData] {
        guard let modelContext = modelContext else { throw StorageError.contextNotAvailable }
        let predicate = #Predicate<NotebookData> { $0.parent == nil }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    
    func insert(notebookData: NotebookData) throws {
        guard let modelContext = modelContext else { throw StorageError.contextNotAvailable }
        modelContext.insert(notebookData)
        try modelContext.save()
    }
}
