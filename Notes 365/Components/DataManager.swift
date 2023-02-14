//
//  DataManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 29/12/22.
//

import Foundation

enum DataEnvironment {
    case local
    case cloud
    case customPath(URL)
    
    var baseURL: URL {
        switch self {
        case .local:
            return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        case .cloud:
            return(FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"))!
        case .customPath(let url):
            return url
        }
    }
}

class DataManager {
    
    private var environment: DataEnvironment {
        didSet {
            basePathURL = environment.baseURL
            print(basePathURL)
        }
    }
    
    var basePathURL: URL
    
    init(environment: DataEnvironment) {
        self.environment = environment
        basePathURL = environment.baseURL
    }
    
}

// MARK: - Folder Operations
extension DataManager {
    
    func createFolder(_ folderName: String) {
        
        let directoryURL = basePathURL.appendingPathComponent(folderName, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print("folder already exists ", directoryURL.path)
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
