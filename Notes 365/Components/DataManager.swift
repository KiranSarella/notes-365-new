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

class ChooseEnvironment: ObservableObject {
    
    // based on preferences
    // if cloud, then intereact with cloud service and get its url or respective error
    // or if local, then get it from local filemanager
    // or if test env/user provided/custom url, use it to initialize.
    
    @Published var isConfigured: Bool = false
    
//    var isConfigured: Bool {
//        EnvironmentState.shared.basePathURL != nil
//    }
    
    var cloudService: CloudServiceTwo!
    
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
            let value = cloudService.getCloudPath()
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
    
    
    func checkOldDataSync() async {
        return await withCheckedContinuation({ continuation in
            guard let cloudURL = environmentState.basePathURL else { return continuation.resume() }
            print(cloudURL)
            // step 1:
            // if cloud folder is empty - continue work else return
            let plistURL = cloudURL.appending(path: Constants.notebooksListPath).appendingPathExtension("plist")
            
            if FileManager.default.fileExists(atPath: plistURL.path(percentEncoded: false)) {
                // items already exists.
                return continuation.resume()
            }
            // step 2:
            // check if local contains items
            let localURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
//            print(localURL.path(percentEncoded: false))
            
            let localItems = try? FileManager.default.contentsOfDirectory(atPath: localURL.path(percentEncoded: false))
//            print(localItems)
            guard let localItems = localItems, localItems.count > 0 else {
                // local is also empty
                return continuation.resume()
                
            }
            // contains local items
            
            // convert to new structure - flat
            // get notebooks list for paths
            func retrieveNotebooks() -> [Notebook]? {
                
                let localPlistURL = localURL.appending(path: Constants.notebooksListPath).appendingPathExtension("plist")
                
                do {
                    // Read the file contents
                    let plistData = try Data(contentsOf: localPlistURL)
                    let notebooksList = try PropertyListDecoder().decode([Notebook].self, from: plistData)
                    return notebooksList
                } catch let error as NSError {
                    print("Failed reading from URL: \(localPlistURL), Error: " + error.localizedDescription)
                }
                return nil
            }
            guard let notebooks = retrieveNotebooks(), notebooks.count > 0 else { return continuation.resume() }
            // /notebooks to /notebooks-flat
            DispatchQueue.global().sync {
                convertToFlatStructure(notebooks: notebooks, localPath: localURL, cloudPath: cloudURL)
            }
            
//            convertToFlatStructure(notebooks: notebooks, localPath: localURL, cloudPath: cloudURL)
            
            sleep(10)
            
            // copy all data from local/sandbox to cloud
            for localItemName in localItems {
                
                if localItemName == "notebooks" { continue }
                
                let localItemURL = localURL.appending(component: localItemName)
                let cloudItemURL = cloudURL.appending(component: localItemName)
                do {
                    try FileManager.default.copyItem(at: localItemURL, to: cloudItemURL)
                } catch let error {
                    print(error)
                }
            }
            // wait for some time, bcz moveItem is not async and no completion status given
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // move items logic
                return continuation.resume()
            }
            // step 3:
            // convert notebooks to new folder structure
            
        })
        
        
    }
    

    
    func convertToFlatStructure(notebooks: [Notebook], localPath: URL, cloudPath: URL) {
//        return await withCheckedContinuation({ continuation in
            
            func traverse(notebooks: [Notebook]) {
                // traverse and add each item to hash map
                for notebook in notebooks {
                    // move to base folder
                    
                    let oldFolderPath = localPath.appendingPathComponent(Constants.notebooksPathOld).appendingPathComponent(notebook.oldFilePath)
                    let newFolderPath = cloudPath.appendingPathComponent(Constants.notebooksPath).appendingPathComponent(notebook.id.uuidString).appendingPathExtension("md")
                    
                    do {
                        try FileManager.default.copyItem(at: oldFolderPath, to: newFolderPath)
                    } catch let error as NSError {
                        print("Ooops! Something went wrong: \(error)")
                    }
                    
                    // handle children
                    if let children = notebook.children {
                        traverse(notebooks: children)
                    }
                }
            }
            // create new
            let newFolderPath = cloudPath.appendingPathComponent(Constants.notebooksPath)
            try? FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true)
            // start traversing
            traverse(notebooks: notebooks)
            
            // for each item
            // get its path
            // move to /notebooks with id.md
            // wait for some time, bcz moveItem is not async and no completion status given
//            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                // move items logic
//                return continuation.resume()
//            }
            
//        })
        
        
    }
}

class EnvironmentState {
    
    static let shared = EnvironmentState()
    
    private(set) var basePathURL: URL! = nil
    
    func setBasePath(url: URL) {
        basePathURL = url
    }
    
}


class DataManager {
  
    var basePathURL: URL
    
    init(path baseURL: URL) {
        basePathURL = baseURL
    }
    
}

// MARK: - Folder Operations
extension DataManager {
    
    func createFolder(_ folderName: String) {
        
        let directoryURL = basePathURL.appendingPathComponent(folderName, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
//            print("folder already exists ", directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func renameItem(from oldPath: String, to newPath:String) {
        
        let oldFolderPath = basePathURL.appendingPathComponent(oldPath)
        let newFolderPath = basePathURL.appendingPathComponent(newPath)
        
        do {
            try FileManager.default.moveItem(atPath: oldFolderPath.path, toPath: newFolderPath.path)
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func deleteItem(at path: String) {
        
        let directoryURL = basePathURL.appendingPathComponent(path, isDirectory: true)
        
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // create/update file with content
    func writeToFile(content: String, fileName: String, folderPath: String, ext: String) {
        
        let folderURL = basePathURL.appendingPathComponent(folderPath)
        let fileURL = folderURL.appendingPathComponent(fileName).appendingPathExtension(ext)
        
        do {
            // create intermediate folders if not exists
            if itemExists(atPath: folderPath) == false {
                createFolder(folderPath)
            }
            // Write to the file
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    // both folder and file
    func itemExists(atPath path: String) -> Bool {
        let itemURL = basePathURL.appendingPathComponent(path, isDirectory: false)
        return FileManager.default.fileExists(atPath: itemURL.path)
    }
    
    
    func removeItem(at path: String) {
        
        let itemURL = basePathURL.appendingPathComponent(path, isDirectory: false)
        
        do {
            try FileManager.default.removeItem(at: itemURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension DataManager {
    
    func persistNotebooks(_ notebooks: [Notebook]) {
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(notebooks)
            // prepare path
            let fileURL = basePathURL.appendingPathComponent(Constants.notebooksListPath).appendingPathExtension("plist")
            // save file
            do {
                // Write to the file
                try plistData.write(to: fileURL)
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        } catch {
            print("Save Failed")
        }
    }
    
    // retrives notebooks hierarcy from plist, not the notebook content.
    func retrieveNotebooks() -> [Notebook]? {
        let fileURL = basePathURL.appendingPathComponent(Constants.notebooksListPath).appendingPathExtension("plist")
        do {
            // Read the file contents
            let plistData = try Data(contentsOf: fileURL)
            let notebooksList = try PropertyListDecoder().decode([Notebook].self, from: plistData)
            return notebooksList
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        return nil
    }
}
