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
            return "icould not access iCloud"
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
    
}
