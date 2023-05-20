//
//  NotebooksListSync.swift
//  Notes 365
//
//  Created by Kiran Sarella on 20/04/23.
//

import Foundation

class NotebooksListSync {
    
    var notDownloadedItems = [NSMetadataItem]()
    
    var basePathURL: URL
    var metadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    var isSyncingStarted: (() -> ())?
    var isSyncingCompleted: (() -> ())?
    
    init(basePathURL: URL) {
        self.basePathURL = basePathURL
        initialGatheringSync()
    }
    
    private func stopMonitoring() {
        metadataQuery.stop()
        metadataQuery.disableUpdates()
    }
    
    func restartGathering() {
        stopMonitoring()
        initialGatheringSync()
    }
    
    func initialGatheringSync() {
        
        // https://stackoverflow.com/questions/49066409/nsmetadataquery-by-folders-ios
        
        // query
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        // define predicate
        let filePath = basePathURL
            .appendingPathComponent(Constants.notebooksPListName)
            .appendingPathExtension("plist")
            .path(percentEncoded: false)
        let searchPredicate = NSPredicate(format: "%K LIKE %@", argumentArray: [NSMetadataItemPathKey, filePath])
        metadataQuery.predicate = searchPredicate
        
        // initial gathering start
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidStartGathering(_:)), name: .NSMetadataQueryDidStartGathering, object: metadataQuery)
        
        // initial gathering progress
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryGatheringProgress(_:)), name: .NSMetadataQueryGatheringProgress, object: metadataQuery)
        
        // initial gathering finish
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidFinishGathering(_:)), name: .NSMetadataQueryDidFinishGathering, object: metadataQuery)
        
        
        // update
//        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: metadataQuery)
        
//        metadataQuery.enableUpdates()
        metadataQuery.start()
    }
    
    @objc func metadataQueryDidStartGathering(_ notification: NSNotification) {
//        print(#function)
//
//        print("isStarted", metadataQuery.isStarted,
//              "isGathering", metadataQuery.isGathering,
//              "isStopped", metadataQuery.isStopped)
    }
    
    @objc func metadataQueryGatheringProgress(_ notification: NSNotification) {
        //        print(#function)
    }
    
    @objc func metadataQueryDidFinishGathering(_ notification: NSNotification) {
//        print(#function)
        metadataQuery.stop()
        handleMetadataQueryResult(notification)
    }
    
    func handleMetadataQueryResult(_ notification: NSNotification) {
        //        print(#function)
        
        guard let metadataQuery = notification.object as? NSMetadataQuery else { return }
        // pause updates till all results are processed
        //        metadataQuery.stop()
        
        isSyncingStarted?()
//        metadataQuery.disableUpdates()
        
        guard let results = metadataQuery.results as? [NSMetadataItem] else { return }
        
//        print("Results count: \(metadataQuery.resultCount)")
        
        let changedMetadataItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem]
        
        let removedMetadataItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem]
        
        let addedMetadataItems = notification.userInfo?[NSMetadataQueryUpdateAddedItemsKey] as? [NSMetadataItem]
        
//        print("changedMetadataItems", changedMetadataItems,
//              "removedMetadataItems", removedMetadataItems,
//              "addedMetadataItems", addedMetadataItems)
        
        for item in results {
            guard let itemURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { return }
            print(itemURL.path(percentEncoded: false))
            // download status
            guard let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String else { return }
            print(downloadStatus)
            
            if downloadStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                // there is a local version of this item and it is the most up-to-date version known to this device.
                
                // ready to open the doc
                //                self.openDocument()
            } else if downloadStatus == NSMetadataUbiquitousItemDownloadingStatusDownloaded {
                // there is a local version of this item available. The most current version will get downloaded as soon as possible.
                
                // open it and listen to document change notification
                //                self.openDocument()
            } else if downloadStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded {
                // this item has not been downloaded yet. Use startDownloadingUbiquitousItemAtURL:error: to download it.
                
                // download manually - startDownloadingUbiquitousItemAtURL
                self.downloadFile(itemURL, item: item)
            }
            
            
            // error
            if let error = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? NSError {
                print(error)
                return
            }
        }
//        metadataQuery.enableUpdates()
//        isSyncingCompleted?()
//        print("isStarted", metadataQuery.isStarted,
//              "isGathering", metadataQuery.isGathering,
//              "isStopped", metadataQuery.isStopped)
        
        // wait for some time, bcz moveItem is not async and no completion status given
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // move items logic
            self.isSyncingCompleted?()
        }
        
        //        startMonitoringChanges()
    }
    
    func downloadFile(_ cloudUrl: URL, item: NSMetadataItem) {
        print(#function)
        notDownloadedItems.append(item)
        print(cloudUrl.path(percentEncoded: false))
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: cloudUrl)
        } catch let error {
            print(#function)
            print(error)
        }
    }
    
    
    @objc func metadataQueryDidUpdate(_ notification: NSNotification) {
//        print(#function)
        handleMetadataQueryResult(notification)
    }
    
}


