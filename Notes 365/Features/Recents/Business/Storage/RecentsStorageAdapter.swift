//
//  RecentsStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation
import SwiftData

class RecentsStorageAdapter: RecentsStorageProvider {
    let storage: RecentsStorage
    
    init(modelContext: ModelContext) {
        storage = RecentsStorage(modelContext: modelContext)
    }
    
    func fetchRecentItems() throws -> [RecentItem] {
        try storage.fetchRecentItems().map { $0.businessModel }
    }
    
    func insert(item: RecentItem) throws {
        try storage.insert(data: item.storageData)
    }
    
    func remove(id: UUID) throws {
        try storage.remove(for: id)
    }
    
    func removeItems(below date: Date, isFolder: Bool) throws {
        try storage.removeItems(below: date, isFolder: isFolder)
    }
}

extension RecentItem {
    var storageData: RecentItemData {
        RecentItemData(id: id, name: name, isFolder: isFolder, updatedDate: updatedDate)
    }
}

extension RecentItemData {
    var businessModel: RecentItem {
        RecentItem(id: id, name: name, isFolder: isFolder, updatedDate: updatedDate)
    }
}
