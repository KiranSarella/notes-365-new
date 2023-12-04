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
        let predicate = #Predicate<DayVersionData> {
            $0.date <= belowDate
        }
        try modelContext.delete(model: DayVersionData.self, where: predicate)
    }
    
    func isBaseVersionExists(for verionId: String) throws -> Bool {
        let predicate = #Predicate<DayVersionData> {
            $0.id == verionId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return results.count > 0
    }
    
    func create(todayVersion: DayVersionData) throws {
        modelContext.insert(todayVersion)
        try modelContext.save()
    }
    
    func getTodayVersion(for versionId: String) throws -> String? {
        let predicate = #Predicate<DayVersionData> {
            $0.id == versionId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.content
    }
    
    func removeDayVersion(for verionId: String) throws {
        let predicate = #Predicate<DayVersionData> {
            $0.id == verionId
        }
        try modelContext.delete(model: DayVersionData.self, where: predicate)
    }
    
}
