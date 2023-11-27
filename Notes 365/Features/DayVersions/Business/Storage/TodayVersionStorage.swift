//
//  TodayVersionStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation
import SwiftData

class TodayVersionStorage {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func deleteAllVersions(belowDate: Date) throws {
        let predicate = #Predicate<TodayVersion> {
            $0.date <= belowDate
        }
        try modelContext.delete(model: TodayVersion.self, where: predicate)
    }
    
    func isBaseVersionExists(for notebookId: UUID) throws -> Bool {
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == notebookId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return results.count > 0
    }
    
    func create(todayVersion: TodayVersion) throws {
        modelContext.insert(todayVersion)
        try modelContext.save()
    }
    
    func getTodayVersion(for notebookId: UUID) throws -> String? {
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == notebookId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.content
    }
    
    func removeDayVersion(for notebookId: UUID) throws {
        let predicate = #Predicate<TodayVersion> {
            $0.notebookID == notebookId
        }
        try modelContext.delete(model: TodayVersion.self, where: predicate)
    }
    
}
