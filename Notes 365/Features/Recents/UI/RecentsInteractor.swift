//
//  RecentsInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

protocol RecentsInteractor {
    func loadRecents() throws -> [RecentItem]
    func addRecent(item: RecentItem) throws
    func clearOldRecentItems()
    func setupRecentsAddingProcess()
    func stopRecentsAddingProcess()
    func rename(id: UUID, name: String) throws
}
