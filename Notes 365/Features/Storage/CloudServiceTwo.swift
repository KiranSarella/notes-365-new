//
//  CloudServiceTwo.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/02/23.
//

import Foundation


public enum CloudError: Error {
    case cloudSyncDisabled
    case cloudDisabled
    case couldNotAccessCloud
    case cloudFileDoesNotExist
    case couldNotReadContent
    case unknown(Error)
    
    var description: String {
        
        switch self {
        case .cloudSyncDisabled:
            return "iCloud sync disabled"
        case .cloudDisabled:
            return "iCloud disabled, please enable to continue"
        case .couldNotAccessCloud:
            return "could not access iCloud"
        case .cloudFileDoesNotExist:
            return "icloud file does not exist"
        case .couldNotReadContent:
            return "icloud not reach content"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

extension CloudError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(self.description, comment: "")
    }
}

final class CloudServiceTwo {
    
    
    var cloudDirectory: String
    
    private var cloudUrl: URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent(cloudDirectory)
    }
    private var lastSyncDate: Date?
    private var cloudObserver: NSObjectProtocol?
    
    private let iCloudQuery = NSMetadataQuery()
    
    var isCloudEnabled: Bool { FileManager.default.ubiquityIdentityToken != nil }
    
    init(cloudDirectory: String = "Documents") {
        
        self.cloudDirectory = cloudDirectory
    }
    
    @discardableResult
    func getCloudPath() -> Result<URL, CloudError> {
        guard isCloudEnabled else { return .failure(.cloudDisabled) }
        guard let cloudUrl = cloudUrl else { return .failure(.couldNotAccessCloud) }
        
        return .success(cloudUrl)
    }
    
    /*
     
     1. if local documents is empty, then
     2. check if cloud contains plist file
        - if so, download plist, /notebooks, /timesheets //msg: checking cloud storage
        - else create empty folders (already logic exists)
     
     ## downloading files
     //msg: downloading cloud files
     can we show progress?
     
     ** imp: we cannot separatly access local cloud and actual cloud - they both are same.
     so.. easy and automatic seems
     
     
     */
    
    func downloadDocumentsContentFromCloud() {
        
        print(#function)
        
        var cloudUrl: URL? {
            FileManager.default
                .url(forUbiquityContainerIdentifier: nil)?
                .appendingPathComponent("Documents/notebooks-list.plist", isDirectory: false)
        }
        
        guard let cloudUrl = cloudUrl else { return }
        print(cloudUrl.path(percentEncoded: false))
        // prepare plist url
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: cloudUrl)
            print("startDownloadingUbiquitousItem")
//            print("isDownloading: \(isDownloading)")
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }//do catch
        
    }
    
}
