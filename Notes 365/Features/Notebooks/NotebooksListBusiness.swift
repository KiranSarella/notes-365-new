//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import UIKit

extension  Notification.Name {
    public static let notebookChangeNotification = Notification.Name("NotebookChangeNotification")
}

public enum NotebookBusinessError: Error {
    case alreadyExists
    case invalidCharacters
    case invalidSelection
}

class NotebooksListBusiness {
    
    var basePathURL: URL
    private var syncDate: Date = Date()
    
    let notebooksPath = Constants.notebooksFolderName
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
    }
    
    func isReloadRequired() -> Bool {
        
        // get modifiedDate of the physical file
        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")

        if let modifiedDate = fileModificationDate(url: plistURL) {
            if modifiedDate > syncDate {
                // reload data
                return true
            } else {
                // no new data exits
                return false
            }
        } else {
            return true
        }
    }
    
    
//    func reloadNotebooksListIfRequired(completion:([Notebook]?)->()) {
//
//        // get modifiedDate of the physical file
//        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")
//
//        if let modifiedDate = fileModificationDate(url: plistURL) {
//            if modifiedDate > syncDate {
//                // reload data
//                if let notebooks = retrieveNotebooks() {
//                    syncDate = Date()
//                    completion(notebooks)
//                } else {
//                    syncDate = Date()
//                    completion(nil)
//                }
//            } else {
//                // no new data exits
//                completion(nil)
//            }
//        } else {
//            completion(nil)
//        }
//    }
    
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
//    func reloadNotebooksList(completion:()->()) {
//
//        if let notebooks = retrieveNotebooks() {
//            self.notebooks = notebooks
//            syncDate = Date()
//            completion()
//        } else {
//            self.notebooks = [Notebook]()
//            syncDate = Date()
//            completion()
//        }
//    }
    
//    func getNotebooks() -> [Notebook] {
//        return notebooks
//    }
//
//
    
    private func createRequiredFoldersIfNotExists() {
        if !itemExists(atPath: notebooksPath) {
            // create notebooks folder
            // create timeline folder
            // create base/dummy notebook (for consistent top and later level implementations)
            
            createFolder(Constants.notebooksFolderName)
            createFolder(Constants.timelineFolderName)
            createFolder(Constants.todayBaseVersionFolderName)
        }
    }
    
    // both folder and file
    private func itemExists(atPath path: String) -> Bool {
        let itemURL = basePathURL.appendingPathComponent(path, isDirectory: false)
        return FileManager.default.fileExists(atPath: itemURL.path)
    }
    
    private func createFolder(_ folderName: String) {

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
    
    // MARK: - Insert
    func addFirst(notebook: Notebook) {
        // create first notebook inside "/notesbooks"
        createRequiredFoldersIfNotExists()
        // create empty file
        writeToFile(content: "", fileName: notebook.id.uuidString, folderPath: notebooksPath, ext: "md")
    }
    
    // return - (newNotebook, parent, ref notebook Index)
    func insertBelow(notebook: Notebook) {
        writeToFile(content: "", fileName: notebook.id.uuidString, folderPath: notebooksPath, ext: "md")
    }
    
    func insertInside(notebook: Notebook) {
        // create phycical file
        writeToFile(content: "", fileName: notebook.id.uuidString, folderPath: notebooksPath, ext: "md")
    }
    
    // create/update file with content
    private func writeToFile(content: String, fileName: String, folderPath: String, ext: String) {

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
    
    // MARK: - Delete
    func deleteNotebook(notebook: Notebook) {
        let filePath = notebooksPath + "/" + notebook.id.uuidString + ".md"
        // delete file.md
        deleteItem(at: filePath)
        
        // if contains child notebooks (and nested childs), delete all them recursively
        
    }
    
    private func deleteItem(at path: String) {
        let directoryURL = basePathURL.appendingPathComponent(path, isDirectory: true)

        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}


// MARK: - Persist Notebooks Hierarchy
extension NotebooksListBusiness {
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persist(notebooks: [Notebook]) {
        syncDate = Date()
        
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(notebooks)
            // prepare path
            let fileURL = basePathURL.appendingPathComponent(Constants.notebooksPListName).appendingPathExtension("plist")
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
        
        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")
        
        do {
            // Read the file contents
            let plistData = try Data(contentsOf: plistURL)
            let notebooksList = try PropertyListDecoder().decode([Notebook].self, from: plistData)
            return notebooksList
        } catch let error as NSError {
            print("Failed reading from URL: \(plistURL), Error: " + error.localizedDescription)
        }
        return nil
    }
    
    
}

// MARK: - Recently Deleted
class DeletedNotebooks: Codable {
    var notebooks: [Notebook] = []
    var paths: [String: [String]] = [:]
    var siblings: [String: String] = [:]
    
}

extension NotebooksListBusiness {
    
    func restore(notebook:  Notebook, in notebooks: inout [Notebook], at path: [String], sibling: String?) {
        // if parent is not nil, reach its root parent, then restore this parent.
        // get parent ref to insert
        
        if path.count == 0 && sibling != nil {
            // base level
            guard let siblingIndex = notebooks.firstIndex(where: { $0.id.uuidString == sibling! }) else { return }
            notebooks.insert(notebook, at: siblingIndex + 1)
        }
        
        
        var ref: Notebook
        guard let baseRef = notebooks.first(where: { $0.id.uuidString == path[0] }) else { return }
        ref = baseRef
        
        if path.count >= 2 {
            for i in 1..<path.count {
                let id = path[i]
                guard let baseRef = ref.children?.first(where: { $0.id.uuidString == path[0] }) else { return }
                ref = baseRef
            }
        }
        
        if let sibling = sibling {
            let siblingIndex = ref
        }
        
    }
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persistDeleted(notebooks: DeletedNotebooks) {
        syncDate = Date()
        
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(notebooks)
            // prepare path
            let fileURL = basePathURL.appendingPathComponent(Constants.deletedNotebooksPListName).appendingPathExtension("plist")
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
    func retrieveDeletedNotebooks() -> DeletedNotebooks? {
        
        let plistURL = basePathURL.appending(path: Constants.deletedNotebooksPListName).appendingPathExtension("plist")
        
        do {
            // Read the file contents
            let plistData = try Data(contentsOf: plistURL)
            let notebooksList = try PropertyListDecoder().decode(DeletedNotebooks.self, from: plistData)
            return notebooksList
        } catch let error as NSError {
            print("Failed reading from URL: \(plistURL), Error: " + error.localizedDescription)
        }
        return nil
    }
}
