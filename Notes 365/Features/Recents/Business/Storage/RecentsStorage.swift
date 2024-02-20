//
//  RecentsStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation
import SwiftData

class RecentsStorage {
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    func fetchRecentFiles() throws -> [RecentItemData] {
        let predicate = #Predicate<RecentItemData> { $0.isFolder == false }
        let sortDescriptor = SortDescriptor(\RecentItemData.updatedDate, order: .reverse)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortDescriptor])
        descriptor.fetchLimit = 20
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRecentFolders() throws -> [RecentItemData] {
        let predicate = #Predicate<RecentItemData> { $0.isFolder == true }
        let sortDescriptor = SortDescriptor(\RecentItemData.updatedDate, order: .reverse)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortDescriptor])
        descriptor.fetchLimit = 20
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRecentFilesCount() throws -> Int {
        let predicate = #Predicate<RecentItemData> { $0.isFolder == false }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetchCount(descriptor)
    }
    
    func fetchRecentFoldersCount() throws -> Int {
        let predicate = #Predicate<RecentItemData> { $0.isFolder == true }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetchCount(descriptor)
    }
    
    func fetchRecentItems() throws -> [RecentItemData] {
        let allListPredicate = #Predicate<RecentItemData> { _ in true }
        let descriptor = FetchDescriptor(predicate: allListPredicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRecentItem(id: UUID) throws -> RecentItemData? {
        let predicate = #Predicate<RecentItemData> { item in item.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func insert(data: RecentItemData) throws {
        modelContext.insert(data)
        try modelContext.save()
    }
    
    func update(data: RecentItemData) throws {
        try data.modelContext?.save()
    }
    
    func remove(for id: UUID) throws {
        let predicate = #Predicate<RecentItemData> {
            $0.id == id
        }
//        var descriptor = FetchDescriptor(predicate: predicate)
//        descriptor.fetchLimit = 1
        try modelContext.delete(model: RecentItemData.self, where: predicate)
    }
    
    func removeItems(below date: Date, isFolder: Bool) throws {
        let predicate = #Predicate<RecentItemData> {
            $0.isFolder == isFolder && $0.updatedDate < date
        }
        try modelContext.delete(model: RecentItemData.self, where: predicate)
    }
    
}
