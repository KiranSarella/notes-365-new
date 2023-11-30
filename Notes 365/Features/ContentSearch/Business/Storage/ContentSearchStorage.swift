//
//  ContentSearchStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import Foundation
import SwiftData

class ContentSearchStorage {
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchSearchResults(for text: String) throws -> [NotebookContentData] {
        
//        let predicate = NSPredicate(format: "text CONTAINS %@", "searchString")
//        let descriptor = FetchDescriptor<NotebookContentData>(predicate: predicate)
//        
        let predicate = #Predicate<NotebookContentData> {
            $0.content.localizedStandardContains(text) //contains(text)
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
}
