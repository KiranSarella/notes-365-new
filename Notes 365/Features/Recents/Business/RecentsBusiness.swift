//
//  RecentsBusiness.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

class RecentsBusiness: RecentsInteractor {
    var storage: RecentsStorageProvider
    
#if DEBUG
    let maxLimit = 10
#else
    let maxLimit = 20
#endif
    
    
    init(storage: RecentsStorageProvider) {
        self.storage = storage
    }
    
    func loadRecents() throws -> [RecentItem] {
        try storage.fetchRecentItems()
    }
    
    func loadRecentFiles() throws -> [RecentItem] {
        try storage.fetchRecentFiles()
    }
    
    func loadRecentFolders() throws -> [RecentItem] {
        try storage.fetchRecentFolders()
    }
    
    func addRecent(item: RecentItem) throws {
        // remove existing
        try storage.remove(id: item.id)
        // insert new
        try storage.insert(item: item)
    }
    
    func remove(id: UUID) throws {
        try storage.remove(id: id)
    }
    
    func rename(id: UUID, name: String) throws {
        try storage.rename(id: id, name: name)
    }
    
    /// clear when exceed 20 items and older then 2 days
    func clearOldRecentItems() {
        logger.info("\(#function)")
        do {
            let filesCount = try storage.fetchRecentFilesCount()
            if filesCount > maxLimit {
                let limitDate = DateTime.now().dayBefore.dayBefore
                try storage.removeItems(below: limitDate, isFolder: false)
            }
            
            let foldersCount = try storage.fetchRecentFoldersCount()
            if foldersCount > maxLimit {
                let limitDate = DateTime.now().dayBefore.dayBefore
                try storage.removeItems(below: limitDate, isFolder: true)
            }
            
        } catch {
            logger.error("\(error)")
        }
        
    }
}

extension RecentsBusiness {
    
    func setupRecentsAddingProcess() {
        logger.info("\(#function)")
        clearOldRecentItems()
        RecentsDataService.shared.startProviding()
    }
    
    func stopRecentsAddingProcess() {
        logger.info("\(#function)")
        RecentsDataService.shared.stopProviding()
    }
}
