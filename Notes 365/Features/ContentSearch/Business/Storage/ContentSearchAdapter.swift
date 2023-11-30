//
//  ContentSearchAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import Foundation
import SwiftData

class ContentSearchStorageAdapter: ContentSearchStorageProvider {
    
    let storage: ContentSearchStorage
    
    init(modelContext: ModelContext) {
        self.storage = ContentSearchStorage(modelContext: modelContext)
    }
    
    func fetchSearchResults(for text: String) throws -> [NotebookContentB] {
        return try storage.fetchSearchResults(for: text).map { $0.notebookContent() }
    }
    
}
