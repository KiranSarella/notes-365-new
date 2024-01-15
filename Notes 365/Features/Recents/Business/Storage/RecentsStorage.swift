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
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        try modelContext.delete(model: RecentItemData.self, where: predicate)
    }
    
    func removeItems(below date: Date, isFolder: Bool) throws {
        let predicate = #Predicate<RecentItemData> {
            $0.isFolder == isFolder && $0.updatedDate < date
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        try modelContext.delete(model: RecentItemData.self, where: predicate)
    }
    
}
