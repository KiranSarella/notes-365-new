//
//  InitialCloudSync.swift
//  Notes 365
//
//  Created by Kiran Sarella on 27/02/23.
//

import Foundation

final class InitialCloudSync {
    
    var notDownloadedItems = [NSMetadataItem]()
    
    var metadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    var timer = Timer()
    
    var timerCount = 0
    var timerMax = 2
    
    var syncCompletionHandler: (()->())?
    var isSyncCalled = false
    
    
    func syncInitialData() {
        // query
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        /*
         // for folders search
         metadataQuery.predicate = NSPredicate(format: "%K LIKE '*'", NSMetadataItemFSNameKey)
         
         
         */
//        metadataQuery.predicate = NSPredicate(format: "%K LIKE '*'", NSMetadataItemFSNameKey)
//        metadataQuery.predicate = NSPredicate(format: "%K LIKE 'notebooks-list.plist'", NSMetadataItemFSNameKey)
        // notifications
        // start
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidStartGathering(_:)), name: .NSMetadataQueryDidStartGathering, object: metadataQuery)
        // update
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: metadataQuery)
//        // progress
//        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryGatheringProgress(_:)), name: .NSMetadataQueryGatheringProgress, object: metadataQuery)
        // finish
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidFinishGathering(_:)), name: .NSMetadataQueryDidFinishGathering, object: metadataQuery)
        
        // gathering error ?
        
        
        metadataQuery.enableUpdates()
        metadataQuery.start()
        
        // start gather time limit
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            // your code here
            if self.isSyncCalled {
                // all ok.
            } else {
                // gathering not happend.
                self.metadataQuery.stop()
                self.metadataQuery.disableUpdates()
                self.syncCompletionHandler?()
            }
        }
    }
    
    @objc func metadataQueryDidStartGathering(_ notification: NSNotification) {
//        print(#function)
        
    }
    
    @objc func metadataQueryDidUpdate(_ notification: NSNotification) {
//        print(#function)
        
        guard let metadataQuery = notification.object as? NSMetadataQuery else { return }
        
        print("Results count: \(metadataQuery.resultCount)")
        
    }
    
    @objc func metadataQueryGatheringProgress(_ notification: NSNotification) {
//        print(#function)
        
        
    }
    
    @objc func metadataQueryDidFinishGathering(_ notification: NSNotification) {
//        print(#function)
        isSyncCalled = true
        guard let metadataQuery = notification.object as? NSMetadataQuery else { return }
        // pause updates till all results are processed
        metadataQuery.stop()
        
        guard let results = metadataQuery.results as? [NSMetadataItem] else { return }
        
        print("Results count: \(metadataQuery.resultCount)")
        
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
        
        // check downloading items progress
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            
            self.timerCount += 1
            
            guard let results = metadataQuery.results as? [NSMetadataItem] else { return }
            
//            print("Timer fired!")
            var downloadedStatus = Set<Bool>()
            
            for item in results {
                
                guard let itemURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { return }
//                print(itemURL.path(percentEncoded: false))
                
                guard let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String else { return }
//                print(downloadStatus)
                
                if downloadStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                    // there is a local version of this item and it is the most up-to-date version known to this
                    downloadedStatus.insert(true)
                } else {
                    downloadedStatus.insert(false)
                }
            }
            
            if downloadedStatus.contains(false) == false || self.timerCount > self.timerMax {
//                print("all downloaded  or - timerCount:\(self.timerCount)")
                
                metadataQuery.disableUpdates()
                timer.invalidate()
                self.syncCompletionHandler?()
            }
        }
    }
    
    func downloadFile(_ cloudUrl: URL, item: NSMetadataItem) {
//        print(#function)
        notDownloadedItems.append(item)
        print(cloudUrl.path(percentEncoded: false))
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: cloudUrl)
        } catch let error {
            print(error)
        }
    }
    
}
