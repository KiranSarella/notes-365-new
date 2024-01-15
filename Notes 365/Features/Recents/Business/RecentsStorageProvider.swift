//
//  RecentsStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

protocol RecentsStorageProvider {
    func fetchRecentItems() throws -> [RecentItem]
    func insert(item: RecentItem) throws
    func remove(id: UUID) throws
    func removeItems(below date: Date, isFolder: Bool) throws
    func rename(id: UUID, name: String) throws
}
