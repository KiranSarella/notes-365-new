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
    
    var syncDate: Date = Date()
    var notebooks = [Notebook]()
    
    let notebooksPath = Constants.notebooksFolderName
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
        
        if let notebooks = retrieveNotebooks() {
            self.notebooks = notebooks
            syncDate = Date()
        } else {
            // no notebooks exists, create empty or base configuration
            self.notebooks = [Notebook]()
            syncDate = Date()
        }
    }
    
    func convertToFlatStructure() {
        print(#function)
        
        func traverse(notebooks: [Notebook]) {
            // traverse and add each item to hash map
            for notebook in notebooks {
                // move to base folder
                
                let oldFolderPath = basePathURL.appendingPathComponent(Constants.notebooksFolderNameOld).appendingPathComponent(notebook.oldFilePath)
                let newFolderPath = basePathURL.appendingPathComponent(notebooksPath).appendingPathComponent(notebook.id.uuidString).appendingPathExtension("md")
                
                do {
                    try FileManager.default.moveItem(atPath: oldFolderPath.path, toPath: newFolderPath.path(percentEncoded: false))
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
        let newFolderPath = basePathURL.appendingPathComponent(notebooksPath)
        try? FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true)
        // start traversing
        traverse(notebooks: notebooks)
        
        // for each item
        // get its path
        // move to /notebooks with id.md
        
    }
    
    func reloadNotebooksListIfRequired(completion:(Bool)->()) {
        
        // get modifiedDate of the physical file
        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")
        
        if let modifiedDate = fileModificationDate(url: plistURL) {
            if modifiedDate > syncDate {
                // reload data
                if let notebooks = retrieveNotebooks() {
                    self.notebooks = notebooks
                    syncDate = Date()
                    completion(true)
                } else {
                    self.notebooks = [Notebook]()
                    syncDate = Date()
                    completion(true)
                }
            } else {
                // no new data exits
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func reloadNotebooksList(completion:()->()) {
        
        if let notebooks = retrieveNotebooks() {
            self.notebooks = notebooks
            syncDate = Date()
            completion()
        } else {
            self.notebooks = [Notebook]()
            syncDate = Date()
            completion()
        }
    }
    
    func getNotebooks() -> [Notebook] {
        return notebooks
    }
    
    func isAlreadyExists(fileName: String, in siblings: [Notebook]) -> Bool {
        return siblings.contains(where: { $0.name == fileName })
    }
    
    func generateFileName(at siblings: [Notebook]?) -> String {
        var count = 1
        var fileName = "Notebook \(count)"
        
        if let siblings = siblings {
            while isAlreadyExists(fileName: fileName, in: siblings) {
                count += 1
                fileName = "Notebook \(count)"
            }
        }
        
        return fileName
    }
    
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
    func addFirstNotes() -> Notebook {
        
        createRequiredFoldersIfNotExists()
        
        // create first notebook inside "/notesbooks"
        let firstBook = createNotebook(parent: nil)
        notebooks.append(firstBook)
        // persist content
        writeToFile(content: "", fileName: firstBook.id.uuidString, folderPath: notebooksPath, ext: "md")
        // persist hierarchy
        persistNotebooks()
        
        return firstBook
    }
    
    
    // return - (newNotebook, parent, ref notebook Index)
    func insertBelow(ref notebook: Notebook) -> (new: Notebook, parent: Notebook?, refIndex: Int) {
        if let parent = notebook.parent {
            // get index of current notebook
            let index = parent.children!.firstIndex(of: notebook)!
            let childNote = insertInside(ref: parent, below: index)
            return (childNote, parent, index)
        } else {
            // base level
            let fullPath = notebooksPath
            let newNotebook = createNotebook(parent: notebook.parent)
            // get index of current notebook
            let index = notebooks.firstIndex(of: notebook)!
            // create object
            notebooks.insert(newNotebook, at: index + 1)
//            // create folder
//            dataManager.createFolder(fullPath)
            // create phycical file
            writeToFile(content: "", fileName: newNotebook.id.uuidString, folderPath: fullPath, ext: "md")
            // persist
            persistNotebooks()
            return (newNotebook, nil, index)
        }
    }
    
    func insertInside(ref notebook: Notebook, below index: Int? = nil) -> Notebook {
        let fullPath = notebooksPath
        let newNotebook = createNotebook(parent: notebook)
        
//        let newNotebook = createNotebook(atPath: fullPath)
        newNotebook.parent = notebook
        
        if let index = index {
            // create object
            notebook.children?.insert(newNotebook, at: index + 1)
            // ..folder already exists
        } else if notebook.children == nil {
            // create object
            notebook.children = [newNotebook]
            // create folder
//            dataManager.createFolder(fullPath)
        } else {
            // create object
            notebook.children?.append(newNotebook)
            // ..folder already exists
        }
        // create phycical file
        writeToFile(content: "", fileName: newNotebook.id.uuidString, folderPath: fullPath, ext: "md")
        // persist
        persistNotebooks()
        return newNotebook
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
    
    // MARK: - Create
    func createNotebook(parent: Notebook?) -> Notebook {
        
        // generate non existed file name at that level
        var fileName = ""
        if let parent = parent {
            fileName = generateFileName(at: parent.children)
        } else {
            fileName = generateFileName(at: notebooks)
        }
        
        return Notebook(id: UUID(), name: fileName)
    }
    
    // MARK: - Delete
    func deleteNotebook(ref notebook: Notebook) {
        let filePath = notebooksPath + "/" + notebook.id.uuidString + ".md"
        if let parent = notebook.parent {
            // delete file.md
            deleteItem(at: filePath)
            // delete notebook
            parent.children!.removeAll(where: { $0 == notebook })
        } else {
            deleteItem(at: filePath)
            // delete notebook
            notebooks.removeAll(where: { $0 == notebook })
        }
        // persist
        persistNotebooks()
    }
    
    private func deleteItem(at path: String) {

        let directoryURL = basePathURL.appendingPathComponent(path, isDirectory: true)

        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func rename(for notebook: Notebook, newValue: String) throws {
        // validate characters
        if newValue.contains(":") {
            throw NotebookBusinessError.invalidCharacters
        }
        // check if already same file name exists
        if let parent = notebook.parent {
            if let children = parent.children {
                if isAlreadyExists(fileName: newValue, in: children) {
                    throw NotebookBusinessError.alreadyExists
                }
            }
        } else {
            if isAlreadyExists(fileName: newValue, in: notebooks) {
                throw NotebookBusinessError.alreadyExists
            }
        }
        
        // store name
        notebook.name = newValue
        persistNotebooks()
    }

    // MARK: - GET
    func getNotebook(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook? {
    
        // goto last level list
        var notebooksList: [Notebook]? = notebooks
        for level in selectedLevels {
            notebooksList = notebooksList?[level].children
        }
        // get notebook from last list
        return notebooksList?[selectedIndex]
    }
    
    func getFolderNamesPath(levels: [Int]) -> String {
        notebooksPath
    }
    
    
}

// MARK: - Folder Paths

extension NotebooksListBusiness {
    
    // recursive
    private func prepareFolderPaths(notebook: Notebook, path: String, fullPaths: inout [UUID: String]) {
        
        // save current level path (until parent only, not saving fileName)
        fullPaths[notebook.id] = path + "/" + notebook.name
        
        // base condition
        if notebook.children == nil {
            // no next level
            return
        }
        
        let currentPath = path + (path.count != 0 ? "/" : "") + notebook.name
        
        // next..
        for child in notebook.children! {
            prepareFolderPaths(notebook: child, path: currentPath, fullPaths: &fullPaths)
        }
    }
    
    func prepareFolderPaths(fullPaths: inout [UUID: String]) {
        
        for notebook in notebooks {
            prepareFolderPaths(notebook: notebook, path: notebooksPath, fullPaths: &fullPaths)
        }
    }
    
}




// MARK: - Persist Notebooks Hierarchy
extension NotebooksListBusiness {
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persistNotebooks() {
//        Task {
//            await saveDocument(with: notebooks)
//        }
        
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
