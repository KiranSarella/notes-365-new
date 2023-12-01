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
    
    func isBaseVersionExists(for versionId: String) throws -> Bool {
        try storage.isBaseVersionExists(for: versionId)
    }
    
    func create(todayVersion: TodayVersion) throws {
        try storage.create(todayVersion: todayVersion)
    }
    
    func getTodayVersion(for versionId: String) throws -> String? {
        try storage.getTodayVersion(for: versionId)
    }
    
    func removeDayVersion(for versionId: String) throws {
        try storage.removeDayVersion(for: versionId)
    }
}
