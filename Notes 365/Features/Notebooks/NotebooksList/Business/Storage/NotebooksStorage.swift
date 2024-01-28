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
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchNotebooksCount() throws -> Int {
        let allListPredicate = #Predicate<NotebookData> { _ in true }
        let descriptor = FetchDescriptor(predicate: allListPredicate)
        return try modelContext.fetchCount(descriptor)
    }
    
    func fetchNotebooks() throws -> [NotebookData] {
        let allListPredicate = #Predicate<NotebookData> { _ in true }
        let descriptor = FetchDescriptor(predicate: allListPredicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRootNotebook() throws -> NotebookData? {
        let predicate = #Predicate<NotebookData> { $0.parent == nil }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func fetchNotebook(for id: UUID) throws -> NotebookData {
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
    
    func searchActiveNotebooks(for searchText: String) throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.deletedDate == nil && $0.name.localizedStandardContains(searchText)}
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchActiveChildren(forParent id: UUID) throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.parent == id && $0.deletedDate == nil }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchActiveTopLevelNotebooks() throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.parent == nil && $0.deletedDate == nil }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    
    func fetchChildren(forParent id: UUID) throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.parent == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func isNotebookExits(for id: UUID) throws -> Bool {
        let predicate = #Predicate<NotebookData> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetchCount(descriptor) > 0
    }
    
    func insert(notebookData: NotebookData) throws {
        modelContext.insert(notebookData)
        try modelContext.save()
    }
   
    func update(notebookData: NotebookData) throws {
        try notebookData.modelContext?.save()
    }
    
    // MARK: - Delete
    func fetchDeletedNotebooks() throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.deletedDate != nil }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchExpiredDeletedNotebooks(expiryDate: Date) throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { $0.deletedDate.flatMap { $0 < expiryDate } == true }
//        let predicate = #Predicate<NotebookData> { $0.deletedDate != nil && $0.deletedDate! < expiryDate}
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func permanentDelete(notebookId: UUID) throws {
        let contentPredicate = #Predicate<NotebookData> {
            $0.id == notebookId
        }
        try modelContext.delete(model: NotebookData.self, where: contentPredicate)
    }
    
//    func deleteAllRecords() throws {
//        try modelContext.delete(model: NotebookData.self)
//    }
    
    
    // MARK: - Info
    func getAllFilesInfo() throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { _ in true }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.propertiesToFetch = [\.id, \.parent, \.name, \.isFolder]
        return try modelContext.fetch(descriptor)
    }
    
    func getAllActiveFolders() throws -> [NotebookData] {
        let predicate = #Predicate<NotebookData> { item in
            item.isFolder && item.deletedDate == nil
        }
        let sortByName = SortDescriptor(\NotebookData.name, order: .forward)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByName])
        descriptor.propertiesToFetch = [\.id, \.parent, \.name]
        return try modelContext.fetch(descriptor)
    }
    
    func fetchOnlyNotesCount() throws -> Int {
        let predicate = #Predicate<NotebookData> { $0.isFolder == false && $0.deletedDate == nil }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetchCount(descriptor)
    }
}
