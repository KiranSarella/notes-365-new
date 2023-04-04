//
//  CloudChangesMonitor.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/02/23.
//

import Foundation

class NotebooksChangeMonitor {
    
    var fileName = "notebooks-list.plist"
    var metadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        metadataQuery.stop()
    }
    
    func startMonitoring() {
        // query
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        // observe only plist file.
        metadataQuery.predicate = NSPredicate(format: "%K LIKE '%@'", NSMetadataItemFSNameKey, fileName)
        // notifications
        // update
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: metadataQuery)
        
        // gathering error ?
        metadataQuery.enableUpdates()
        metadataQuery.start()
    }
    
    @objc func metadataQueryDidUpdate(_ notification: NSNotification) {
//        print(#function)
        
        guard let metadataQuery = notification.object as? NSMetadataQuery else { return }
        
//        print("Results count: \(metadataQuery.resultCount)")
        
        
        
    }
}
