//
//  ContentSearchBusiness.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import Foundation

class ContentSearchBusiness {
    
    var storage: ContentSearchStorageProvider
    
    init(storage: ContentSearchStorageProvider) {
        self.storage = storage
    }
    
    func fetchSearchResults(for text: String) -> [NotebookContentB]? {
        logger.debug("\(#function) - \(text)")
        do {
            let results = try storage.fetchSearchResults(for: text)
            logger.log("\(results)")
            return results
        } catch let error {
            logger.error("\(error.localizedDescription)")
        }
        return nil
    }
}
