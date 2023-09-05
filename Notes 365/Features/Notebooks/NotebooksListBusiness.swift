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
    private var listSyncDate: Date = Date()
    
    private let deleteDays = 30
    
    let notebooksPath = Constants.notebooksFolderName
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
    }
    
    func isReloadRequired() -> Bool {
        
        // get modifiedDate of the physical file
        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")

        if let modifiedDate = fileModificationDate(url: plistURL) {
            if modifiedDate > listSyncDate {
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
        print(#function)
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(notebooks)
            // prepare path
            let fileURL = basePathURL.appendingPathComponent(Constants.notebooksPListName).appendingPathExtension("plist")
            // save file
            do {
                // Write to the file
                try plistData.write(to: fileURL)
                self.listSyncDate = Date()
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
            self.listSyncDate = Date()
            return notebooksList
        } catch let error as NSError {
            print("Failed reading from URL: \(plistURL), Error: " + error.localizedDescription)
        }
        return nil
    }
    
}

// MARK: - Deleted Notebooks
extension NotebooksListBusiness {
    
    func restore(notebook: Notebook) {
        // if parent is not nil, reach its root parent, then restore this parent.
        
        
        
    }
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persistDeleted(notebooks: [Notebook]) {
        listSyncDate = Date()
        
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
    func retrieveDeletedNotebooks() -> [Notebook]? {
        
        let plistURL = basePathURL.appending(path: Constants.deletedNotebooksPListName).appendingPathExtension("plist")
        
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
    
    func deleteDateExceededNotebooks(deletedNotebooks: inout [Notebook]) {
        // delete files that are 30 days old
        
        var oldNotebooks = [Notebook]()
        var remainingNotebooks = [Notebook]()
        
        for notebook in deletedNotebooks {
            guard let deletedDate = notebook.deletedDate else { return }
            if numberOfDaysBetween(deletedDate, and: Date()) > deleteDays {
                oldNotebooks.append(notebook)
            } else {
                remainingNotebooks.append(notebook)
            }
        }
        
        // pyisically delete items
        for notebook in oldNotebooks {
            guard let deletedDate = notebook.deletedDate else { return }
            if numberOfDaysBetween(deletedDate, and: Date()) > deleteDays {
                delete(path: notebook.fileURL)
                // nested items delete
                if notebook.children != nil && notebook.children!.isEmpty == false {
                    deleteNestedPerminantly(deletedNotebooks: notebook.children!)
                }
            }
        }
        
        deletedNotebooks = remainingNotebooks
        
        persistDeleted(notebooks: deletedNotebooks)
    }
    
    func deleteNestedPerminantly(deletedNotebooks: [Notebook]) {
        for notebook in deletedNotebooks {
            delete(path: notebook.fileURL)
            // nested items delete
            if notebook.children != nil && notebook.children!.isEmpty == false {
                deleteNestedPerminantly(deletedNotebooks: notebook.children!)
            }
        }
    }
    
    func delete(path: URL) {
        // delete all files including nested files
        do {
            print("deleting: ", path.absoluteString)
            try FileManager.default.removeItem(at: path)
        } catch (let error) {
            print(error)
        }
    }
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day!
    }
    
}
