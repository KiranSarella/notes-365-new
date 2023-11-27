//
//  TodayVersionStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation
import SwiftData

class TodayVersionStorageAdapter: TodayVersionStorageProvider {
    
    let storage: TodayVersionStorage
    
    init(modelContext: ModelContext) {
        storage = TodayVersionStorage(modelContext: modelContext)
    }
    
    func deleteAllVersions(belowDate: Date) throws {
        try storage.deleteAllVersions(belowDate: belowDate)
    }
    
    func isBaseVersionExists(for notebookId: UUID) throws -> Bool {
        try storage.isBaseVersionExists(for: notebookId)
    }
    
    func create(todayVersion: TodayVersion) throws {
        try storage.create(todayVersion: todayVersion)
    }
    
    func getTodayVersion(for notebookId: UUID) throws -> String? {
        try storage.getTodayVersion(for: notebookId)
    }
    
    func removeDayVersion(for notebookId: UUID) throws {
        try storage.removeDayVersion(for: notebookId)
    }
}
