//
//  RecentsBusiness.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

class RecentsBusiness: RecentsInteractor {
    var storage: RecentsStorageProvider
    let max: Int = 20
    
    init(storage: RecentsStorageProvider) {
        self.storage = storage
    }
    
    func loadRecents() throws -> [RecentItem] {
        try storage.fetchRecentItems()
    }
    
    func addRecent(item: RecentItem) throws {
        // remove existing
        try storage.remove(id: item.id)
        // insert new
        try storage.insert(item: item)
    }
    
    func clearOldRecentItems() {
        logger.info("\(#function)")
        do {
            let allItems = try storage.fetchRecentItems()
            // folders
            let folders = allItems.filter({ $0.isFolder }).sorted { r1, r2 in
                r1.updatedDate < r2.updatedDate
            }
            if folders.count > max {
                let limitDate = folders[max].updatedDate
                try storage.removeItems(below: limitDate, isFolder: true)
            }
            // files
            let files = allItems.filter({ $0.isFolder == false }).sorted { r1, r2 in
                r1.updatedDate < r2.updatedDate
            }
            if files.count > max {
                let limitDate = files[max].updatedDate
                try storage.removeItems(below: limitDate, isFolder: false)
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
