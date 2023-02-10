//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import Foundation

extension  Notification.Name {
    public static let notebookChangeNotification = Notification.Name("NotebookChangeNotification")
}

public enum NotebookBusinessError: Error {
    case alreadyExists
    case invalidCharacters
    case invalidSelection
}

class NotebooksListBusiness {
    
    static let shared = NotebooksListBusiness(dataManager: DataManager(environment: .local))
    var dataManager: DataManager
    var notebooks: [Notebook]
    
//    var notebooksHashMap = [UUID: Notebook]()
    
    private let notebooksLimit = 3
    let notebooksPath = "notebooks"
    
    init(dataManager: DataManager) {
        
        self.dataManager = dataManager
        // no notebooks exists, create empty or base configuration
        self.notebooks = [Notebook]()
        
        if let notebooks = retrieveNotebooks() {
            self.notebooks = notebooks
        }
        
        // convert folder structure to flat structure
//        convertToFlatStructure()
        
        if let isFlat = UserDefaults.standard.value(forKey: "flat-structure-status") as? Bool, isFlat == false {
            // if false
            convertToFlatStructure()
        } else {
            // if not set
            convertToFlatStructure()
        }

        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangeNotification(_:)), name: .notebookChangeNotification, object: nil)
        
        // generate hash map
//        generateNotebooksHashMap()
    }
    
//    @objc func handleNotebookChangeNotification(_ sender: Notification) {
//        print(#function)
//    }
    
//    func generateNotebooksHashMap() {
//        // clean
//        notebooksHashMap.removeAll()
//
//        func traverse(notebooks: [Notebook]) {
//            // traverse and add each item to hash map
//            for notebook in notebooks {
//                // insert
//                notebooksHashMap[notebook.id] = notebook
//                // handle children
//                if let children = notebook.children {
//                    traverse(notebooks: children)
//                }
//            }
//        }
//        // start traversing
//        traverse(notebooks: notebooks)
//    }
    
    func convertToFlatStructure() {

        func traverse(notebooks: [Notebook]) {
            // traverse and add each item to hash map
            for notebook in notebooks {
                // move to base folder
                
                let oldFolderPath = dataManager.basePathURL.appendingPathComponent(notebook.oldFilePath)
                let newFolderPath = dataManager.basePathURL.appendingPathComponent("notebooks").appendingPathComponent(notebook.id.uuidString).appendingPathExtension("md")
                
                
                do {
                    try FileManager.default.moveItem(atPath: oldFolderPath.path, toPath: newFolderPath.path)
                } catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                
                // handle children
                if let children = notebook.children {
                    traverse(notebooks: children)
                }
            }
        }
        // rename existing
        dataManager.renameItem(from: "notebooks", to: "notebooks-old")
        // create new
        let newFolderPath = dataManager.basePathURL.appendingPathComponent("notebooks")
        try? FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true)
        // start traversing
        traverse(notebooks: notebooks)
        // set completion flag
        UserDefaults.standard.set(true, forKey: "flat-structure-status")
        
        // for each item
        // get its path
        // move to /notebooks with id.md
        
    }
    
    func getNotebooks() -> [Notebook] {
        return notebooks
    }
    
    func isNotebooksLimitExceeded() -> Bool {
        
        if notebooks.count >= notebooksLimit {
            return true
        }
        
        func countChilds(for notebook: Notebook) -> Int {
            // base condition
            if notebook.children == nil {
                return 0 // no children
            }
            
            var childrenCount = 0   // current notebook count
            
            for notebook in notebook.children! {
                childrenCount += 1  // count current notebook
                childrenCount += countChilds(for: notebook)
            }
            
            return childrenCount
        }
        
        var notebooksCount = 0
        
        for notebook in notebooks {
            // count deep until limit exceeds
            notebooksCount += 1    // count current notebook
            notebooksCount += countChilds(for: notebook)
        }
        
        return notebooksCount >= notebooksLimit
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
        if !dataManager.itemExists(atPath: "notebooks") {
            // create notebooks folder
            // create timeline folder
            // create base/dummy notebook (for consistent top and later level implementations)
            
            dataManager.createFolder("notebooks")
            dataManager.createFolder("timeline")
            dataManager.createFolder("today_base_version")
        }
    }
    
    // MARK: - Insert
    func addFirstNotes() -> Notebook {
        
        createRequiredFoldersIfNotExists()
        
        // create first notebook inside "/notesbooks"
        let firstBook = createNotebook(parent: nil)
        notebooks.append(firstBook)
        // persist content
        dataManager.writeToFile(content: "", fileName: firstBook.id.uuidString, folderPath: "notebooks", ext: "md")
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
            let fullPath = "notebooks"
            let newNotebook = createNotebook(parent: notebook.parent)
            // get index of current notebook
            let index = notebooks.firstIndex(of: notebook)!
            // create object
            notebooks.insert(newNotebook, at: index + 1)
//            // create folder
//            dataManager.createFolder(fullPath)
            // create phycical file
            dataManager.writeToFile(content: "", fileName: newNotebook.id.uuidString, folderPath: fullPath, ext: "md")
            // persist
            persistNotebooks()
            return (newNotebook, nil, index)
        }
    }
    
    func insertInside(ref notebook: Notebook, below index: Int? = nil) -> Notebook {
        let fullPath = "notebooks"
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
        dataManager.writeToFile(content: "", fileName: newNotebook.id.uuidString, folderPath: fullPath, ext: "md")
        // persist
        persistNotebooks()
        return newNotebook
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
        let filePath = "notebooks/" + notebook.id.uuidString + ".md"
        if let parent = notebook.parent {
            // delete file.md
            
            dataManager.deleteItem(at: filePath)
            // delete notebook
            parent.children!.removeAll(where: { $0 == notebook })
        } else {
            dataManager.deleteItem(at: filePath)
            // delete notebook
            notebooks.removeAll(where: { $0 == notebook })
        }
        // persist
        persistNotebooks()
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
        
        
//        let dirPath = notebook.directoryPath
//        let newFilePath = dirPath + "/" + newValue + ".md"
//        let oldFilePath = dirPath + "/" + notebook.name + ".md"
        
//        if dataManager.itemExists(atPath: newFilePath) {
//            throw NotebookBusinessError.alreadyExists
//        }
//        // rename file
////        dataManager.renameItem(from: oldFilePath, to: newFilePath)
//        // rename folder if exists
//        if notebook.containChildNotebooks {
//            let newFolderPath = dirPath + "/" + newValue
//            let oldFolderPath = dirPath + "/" + notebook.name
//            // rename folder
//            dataManager.renameItem(from: oldFolderPath, to: newFolderPath)
//        }
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
        
        return "notebooks"
        
//        var notebooksList = self.notebooks
//        // base condition
//        if levels.isEmpty {
//            return "notebooks"
//        }
//        var path = "notebooks"
//        for level in levels {
//            path.append("/")
//            path.append(notebooksList[level].name)
//            if notebooksList[level].children != nil {
//                notebooksList = notebooksList[level].children!
//            }
//        }
//        return path
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
            prepareFolderPaths(notebook: notebook, path: "notebooks", fullPaths: &fullPaths)
        }
    }
    
}




// MARK: - Persist Notebooks Hierarchy
extension NotebooksListBusiness {
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persistNotebooks() {
        dataManager.persistNotebooks(notebooks)
    }
    
    // retrives notebooks hierarcy from plist, not the notebook content.
    func retrieveNotebooks() -> [Notebook]? {
        dataManager.retrieveNotebooks()
    }
    
}
