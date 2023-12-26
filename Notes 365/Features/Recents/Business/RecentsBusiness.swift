//
//  RecentsBusiness.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

class RecentsBusiness: RecentsInteractor {
    var storage: RecentsStorageProvider
    
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
}

