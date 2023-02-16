//
//  CloudServiceTwo.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/02/23.
//

import Foundation

final class CloudServiceTwo {
    enum CloudError: Error {
        case cloudSyncDisabled
        case cloudDisabled
        case couldNotAccessCloud
        case cloudFileDoesNotExist
        case couldNotReadContent
        case unknown(Error)
    }
    
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
    
}
