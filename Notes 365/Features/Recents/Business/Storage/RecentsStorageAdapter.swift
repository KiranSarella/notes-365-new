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
    
    func fetchRecentFiles() throws -> [RecentItem] {
        try storage.fetchRecentFiles().map { $0.businessModel }
    }
    
    func fetchRecentFolders() throws -> [RecentItem] {
        try storage.fetchRecentFolders().map { $0.businessModel }
    }
    
    func fetchRecentFilesCount() throws -> Int {
        try storage.fetchRecentFilesCount()
    }
    
    func fetchRecentFoldersCount() throws -> Int {
        try storage.fetchRecentFoldersCount()
    }
    
    func fetchRecentItems() throws -> [RecentItem] {
        try storage.fetchRecentItems().map { $0.businessModel }
    }
    
    func insert(item: RecentItem) throws {
        try storage.insert(data: item.storageData)
    }
    
    func rename(id: UUID, name: String) throws {
        if let oldData = try storage.fetchRecentItem(id: id) {
            oldData.name = name
            try storage.update(data: oldData)
        }
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
