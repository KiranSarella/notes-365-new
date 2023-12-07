//
//  DataManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 29/12/22.
//

import Foundation


enum EnvironmentType {
    case cloud
    case local
    case custom(URL)
}

@Observable
class ChooseEnvironment {
    
    // based on preferences
    // if cloud, then intereact with cloud service and get its url or respective error
    // or if local, then get it from local filemanager
    // or if test env/user provided/custom url, use it to initialize.
    
    var isConfigured: Bool = false
    
//    var isConfigured: Bool {
//        EnvironmentState.shared.basePathURL != nil
//    }
    
    var cloudService: CloudServiceTwo? = nil
    
//    var cloudDocumentSync: iCloud = iCloud.sharedCloud
    
//    var cloudServiceOld = CloudService(cloudDirectory: "Documents", cloudSyncFileName: "notebooks-list.plist")
    
    let cloudSync = InitialCloudSync()
    
    let environmentState = EnvironmentState.shared
    
    init() {
        
    }
    
    func enableConfigured() {
        DispatchQueue.main.async {
            self.isConfigured = true
        }
    }
    
    func setEnviromment(with environmentType: EnvironmentType) throws {
        switch environmentType {
        case .cloud:
            // if cloud, then intereact with cloud service and get its url or respective error
            cloudService = CloudServiceTwo()
            let value = cloudService!.getCloudPath()
            switch value {
            case .success(let url):
                print(url.path(percentEncoded: false))
                environmentState.setBasePath(url: url)
            case .failure(let error):
                throw error
            }
            
            break
        case .local:
            // if local, then get it from local filemanager
            let localURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
            environmentState.setBasePath(url: localURL)
            break
        case .custom(let url):
            // if test env/user provided/custom url, use it to initialize.
            environmentState.setBasePath(url: url)
            break
        }
        
    }
    
    func downloaodCloudDocuments(completion:  @escaping (()->())) {
        cloudSync.syncCompletionHandler = {
            completion()
        }
        cloudSync.syncInitialData()
    }
    
    // why it is not working - why metaquery finish method is not getting called?
//    func downloaodCloudDocuments() async {
//        return await withCheckedContinuation { continuation in
//            cloudSync.syncCompletionHandler = {
//                return continuation.resume()
//            }
//            cloudSync.syncInitialData()
//        }
//    }
    

}

class EnvironmentState {
    
    static let shared = EnvironmentState()
    
    private(set) var basePathURL: URL! = nil
    
    func setBasePath(url: URL) {
        basePathURL = url
    }
    
}
