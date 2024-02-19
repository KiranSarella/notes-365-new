//
//  Constants.swift
//  Notes 365
//
//  Created by Kiran Sarella on 10/02/23.
//

import Foundation
import SwiftData

class Constants {
    
    static let notebooksFolderNameOld = "notebooks"
    static let notebooksFolderName = "notebooks-flat"
    static let timelineFolderName = "timeline"
    static let todayBaseVersionFolderName = "today_base_version"
    static let notebooksPListName = "notebooks-list"
    static let deletedNotebooksPListName = "deleted-notebooks-list"
}

@Model
class UserPreferenceData {
    var id = UUID()
    var isMigrationDone = false
    
    init() {
        
    }
}

class UserPreferenceStorage {
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchUserPreference() throws -> UserPreferenceData? {
        logger.info("\(#function)")
        let contentPredicate = #Predicate<UserPreferenceData> { _ in true
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    func containsUserPreference() throws -> Bool {
        logger.info("\(#function)")
        let contentPredicate = #Predicate<UserPreferenceData> { _ in true
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        let result = try modelContext.fetchCount(descriptor)
        return result > 0
    }
    
    func insert(data: UserPreferenceData) throws {
        logger.info("\(#function)")
        let containsUserPref = try containsUserPreference()
        if containsUserPref {
            try update(data: data)
        } else {
            modelContext.insert(data)
            try modelContext.save()
        }
    }
    
    func update(data: UserPreferenceData) throws {
        logger.info("\(#function)")
        try data.modelContext?.save()
    }
}
