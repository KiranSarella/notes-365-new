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

class NotebooksListBusiness {
    
    static let shared = NotebooksListBusiness()
    
    var notebooks: [Notebook]!
    
//    var notebooksHashMap = [UUID: Notebook]()
    
    private let notebooksLimit = 3
    
    private init() {
        
        if let notebooks = NotebooksListBusiness.retrieveObject() {
            self.notebooks = notebooks
        } else {
            // no notebooks exists, create empty or base configuration
            self.notebooks = [Notebook]()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangeNotification(_:)), name: .notebookChangeNotification, object: nil)
        
        // generate hash map
//        generateNotebooksHashMap()
    }
    
    @objc func handleNotebookChangeNotification(_ sender: Notification) {
        print(#function)
    }
    
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
    
    func getNotebooks() -> [Notebook] {
        return notebooks
    }
    
//    func addFirstNotebook() -> Notebook {
//        let note1 = Notebook(id: UUID(), name: "Notebook 1")
//
//        notebooks = [note1]
//
//        return note1
//    }
    
//    func addNotebookInside(id: UUID) -> Notebook {
//        // new notebook
//        let newNotebook = Notebook(id: UUID(), name: "Notebook 2")
//        // add to hierarchy
//        if notebooksHashMap[id]?.children == nil {
//            notebooksHashMap[id]?.children = [newNotebook]
//        } else {
//            notebooksHashMap[id]?.children?.append(newNotebook)
//        }
//        // update hashmap
//        notebooksHashMap[newNotebook.id] = newNotebook
//
//        return newNotebook
//    }
    
    
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
    
   
    func generateFileName(atPath path: String) -> String {
        
        var count = 1
        var fileName = "Notebook \(count)"
        
        while FilesHelper.shared.fileExists(atPath: path, fileName: fileName) {
            count += 1
            fileName = "Notebook \(count)"
        }
        
        return fileName
    }
    
    func persistNotebooks() {
        // persist
        NotebooksListBusiness.persistObject(notebooks: notebooks)
    }
    
    // MARK: - Insert
    func addFirstNotes() -> Notebook {
        
        // if no plist or notebooks folder exists, then create it
        if FilesHelper.shared.folderExists(atPath: "notebooks") == false {
            // create notebooks folder
            // create timeline folder
            // create base/dummy notebook (for consistent top and later level implementations)
            
            
            FilesHelper.shared.createDirectory(folderName: "notebooks")
            FilesHelper.shared.createDirectory(folderName: "timeline")
            FilesHelper.shared.createDirectory(folderName: "today_base_version")
        }
        
        // create first notebook inside "/notesbooks"
        let firstBook = createNotebook(atPath: "notebooks")
        notebooks.append(firstBook)
        // write content
        FilesHelper.shared.writeToFile(fileName: firstBook.name, folderPath: "notebooks", content: "")
        
        // persist
        persistNotebooks()
        
        return firstBook
    }
    
    /*
     goto target level and insert a new notebook below the target index.
     */
    func insertUserBelowSelection(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook {
        
        if selectedLevels.isEmpty {
            // top level
            let path = "notebooks"
            
            let notebook = createNotebook(atPath: path)
            notebooks.insert(notebook, at: selectedIndex + 1)
            
            FilesHelper.shared.writeToFile(fileName: notebook.name, folderPath: path, content: "")
            
            // persist
            persistNotebooks()
            
            return notebook
            
        } else {
            
            var baseLevel = selectedLevels.first!
            var levels = selectedLevels
            levels.removeFirst()
            
            var newNotebook: Notebook!
            
            func getSelectedNotebookReference(notebook: Notebook) {
                
                // when referered to last level (ie selected notebook)
                if levels.count <= 0 {
                    
                    // get path for all folders using level numbers
                    let fullPath = getFolderNamesPath(levels: selectedLevels)
                    newNotebook = createNotebook(atPath: fullPath)
                    
                    let insertIndex = selectedIndex + 1
                    // check index out
                    if let count = notebook.children?.count, count >= insertIndex {
                        notebook.children?.insert(newNotebook, at: selectedIndex + 1)
                    } else {
                        notebook.children?.append(newNotebook)
                    }
                    
                    FilesHelper.shared.writeToFile(fileName: newNotebook.name, folderPath: fullPath, content: "")
                    
                    return
                }
                
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: notebook.children![baseLevel])
            }
            
            getSelectedNotebookReference(notebook: notebooks[baseLevel])
            
            // persist
            persistNotebooks()
            
            return newNotebook
        }
    }
    
    
    func insertInsideSelection(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook {
        
        
        if selectedLevels.isEmpty {
            // top level
            let selectedNotebook = notebooks[selectedIndex]
            
            let fullPath = "notebooks" + "/" + "\(selectedNotebook.name)"
            
            let notebook = createNotebook(atPath: fullPath)
            
            if selectedNotebook.children == nil {
                
                // create object
                notebooks[selectedIndex].children = [notebook]
                // create folder
                FilesHelper.shared.createDirectory(folderName: fullPath)
                // create file
                FilesHelper.shared.writeToFile(fileName: notebook.name, folderPath: fullPath, content: "")
            } else {
                // create object
                notebooks[selectedIndex].children?.append(notebook)
                // folder already exists
                FilesHelper.shared.writeToFile(fileName: notebook.name, folderPath: fullPath, content: "")
            }
            // persist
            NotebooksListBusiness.persistObject(notebooks: notebooks)
            
            return notebook
            
        } else {
            
            var selectedLevels = selectedLevels
            selectedLevels.append(selectedIndex) // because selectedIndex is the last level
            
            var baseLevel = selectedLevels.first!
            
            var levels = selectedLevels
            levels.removeFirst() // remove base level
            
            var newNotebook: Notebook!
            
            // get selected Notebook reference (bcz we are using struct, we need use assignment)
            func getSelectedNotebookReference(notebook: Notebook) {
                
                // base condition
                if levels.count <= 0 {
                    
                    // get path for all folders using level numbers
                    let fullPath = getFolderNamesPath(levels: selectedLevels)
                    newNotebook = createNotebook(atPath: fullPath)
                    
                    if notebook.children == nil {
                        // create object
                        notebook.children = [newNotebook]
                        // create folder
                        FilesHelper.shared.createDirectory(folderName: fullPath)
                        // create file
                        FilesHelper.shared.writeToFile(fileName: newNotebook.name, folderPath: fullPath, content: "")
                    } else {
                        // create object
                        notebook.children?.append(newNotebook)
                        // folder already exists
                        // create file
                        FilesHelper.shared.writeToFile(fileName: newNotebook.name, folderPath: fullPath, content: "")
                    }
                    
                    return
                }
                
                // next level
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: notebook.children![baseLevel])
                
            }
            
            getSelectedNotebookReference(notebook: notebooks[baseLevel])
            
            // persist
            persistNotebooks()
            
            return newNotebook
        }
    }
    
    func insertInside(ref notebook: Notebook) -> Notebook {
        
        // get path for all folders using level numbers
        let fullPath = notebook.folderPath
        let newNotebook = createNotebook(atPath: notebook.folderPath)
        newNotebook.parent = notebook
        
        if notebook.children == nil {
            // create object
            notebook.children = [newNotebook]
            // create folder
            FilesHelper.shared.createDirectory(folderName: fullPath)
            // create file
            FilesHelper.shared.writeToFile(fileName: newNotebook.name, folderPath: fullPath, content: "")
        } else {
            // create object
            notebook.children?.append(newNotebook)
            // folder already exists
            // create file
            FilesHelper.shared.writeToFile(fileName: newNotebook.name, folderPath: fullPath, content: "")
        }
        
        // persist
        NotebooksListBusiness.persistObject(notebooks: notebooks)
        
        return newNotebook
    }
    
    
    // MARK: - Create
    func createNotebook(atPath path: String) -> Notebook {
        
        // generate non existed file name at that level
        let fileName = generateFileName(atPath: path)
        
        return Notebook(id: UUID(), name: fileName)
    }
    
    // MARK: - Delete
    func deleteNotebook(levels selectedLevels: [Int], index selectedIndex: Int) {
        
        if selectedLevels.isEmpty {
            // top level
            let path = "notebooks"
            let fileName = notebooks[selectedIndex].name
            
            // delete file.md
            FilesHelper.shared.deleteFile(fileName: fileName, path: path)
            // delete folder if exists
            let folderPath = path + "/" + fileName
            FilesHelper.shared.deleteFolder(path: folderPath)
            
            // delete object
            notebooks.remove(at: selectedIndex)
        } else {
            
            // remove top level, as we used it.
            var baseLevel = selectedLevels.first!
            var levels = selectedLevels
            levels.removeFirst()
            
            // traverse to inner selected note
            func getSelectedNotebookReference(notebook: Notebook) {
                
                // base condition
                if levels.count <= 0 {
                    
                    // file
                    let fullPath = getFolderNamesPath(levels: selectedLevels)
                    let fileName = notebook.children![selectedIndex].name
                    FilesHelper.shared.deleteFile(fileName: fileName, path: fullPath)
                    // delete folder if exists
                    let folderPath = fullPath + "/" + fileName
                    FilesHelper.shared.deleteFolder(path: folderPath)
                    
                    // reached to deeper level, so remove element
                    notebook.children?.remove(at: selectedIndex)
                    
                    return
                }
                
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: notebook.children![baseLevel])
            }
            
            // if selected level is inner level, then pass
            getSelectedNotebookReference(notebook: notebooks[baseLevel])
        }
        
        // persist
        persistNotebooks()
    }
    
    enum NotebookBusinessError: Error {
        case rename
        case invalidSelection
    }
    
    func renameNotebook(levels selectedLevels: [Int], index selectedIndex: Int, editingFileName: String) throws {
        
        // get folders path
        let path = NotebooksListState.shared.getFolderNamesPath(levels: selectedLevels)
        
        // check if already same file name exists
        if FilesHelper.shared.fileExists(atPath: path, fileName: editingFileName) {
            
            throw NotebookBusinessError.rename
        }
        
        guard let notebook = getNotebook(levels: selectedLevels, index: selectedIndex) else {
            throw NotebookBusinessError.invalidSelection
        }
        
        // rename file
        FilesHelper.shared.renameFile(newFileName: editingFileName, oldFileName: notebook.name, filePath: path)
        
        // rename folder if exists
        if notebook.containChildNotebooks {
            // rename folder
            FilesHelper.shared.renameFolder(new: editingFileName, old: notebook.name, folderPath: path)
        }
        
        // store name
        notebook.name = editingFileName
        
        persistNotebooks()
    }
    
    // MARK: - GET
    
    func getNotebook(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook? {
    
        // goto last level list
        var notebooksList = notebooks
        for level in selectedLevels {
            notebooksList = notebooksList?[level].children
        }
        // get notebook from last list
        return notebooksList?[selectedIndex]
    }
    
    func getFolderNamesPath(levels: [Int]) -> String {
        
        var notebooksList = self.notebooks!
        
        // base condition
        if levels.isEmpty {
            return "notebooks"
        }
        
        var path = "notebooks"
        
        for level in levels {
            
            path.append("/")
            path.append(notebooksList[level].name)
            
            if notebooksList[level].children != nil {
                notebooksList = notebooksList[level].children!
            }
        }
        
        return path
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
        //        dump(fullPaths)
    }
    
}




//// MARK: - Persist Notebooks Hierarchy
//extension NotebooksBusiness {
//
//    // It will save only notebooks list hierarchy to plist, not notebook content.
//    func saveObject(users: [User]) {
//
//        do {
//            // generate data
//            let plistData = try PropertyListEncoder().encode(users)
//
//            // prepare path
//            let DocumentDirURL = CloudDataManager.shared.getDocumentDiretoryURL()
//            
//            //            try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let fileURL = DocumentDirURL.appendingPathComponent("notebooks-list").appendingPathExtension("plist")
//
//            // save file
//            do {
//                // Write to the file
//                try plistData.write(to: fileURL)
//            } catch let error as NSError {
//                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
//            }
//        } catch {
//            print("Save Failed")
//        }
//    }
//
//    // retrives notebooks hierarcy from plist, not the notebook content.
//    func retrieveObject() -> [User]? {
//
//        // prepare path
//        //        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//
//        let DocumentDirURL = CloudDataManager.shared.getDocumentDiretoryURL()
//
//        let fileURL = DocumentDirURL.appendingPathComponent("notebooks-list").appendingPathExtension("plist")
//
//
//        do {
//            // Read the file contents
//            let plistData = try Data(contentsOf: fileURL)
//
//            let notebooksList = try PropertyListDecoder().decode([User].self, from: plistData)
//
//            return notebooksList
//
//        } catch let error as NSError {
//            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//        }
//
//        return nil
//    }
//
//}


// MARK: - Persist Notebooks Hierarchy
extension NotebooksListBusiness {
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    static func persistObject(notebooks: [Notebook]) {
        
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(notebooks)
            
            // prepare path
            let DocumentDirURL = CloudDataManager.shared.getDocumentDiretoryURL()
            
            //            try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent("notebooks-list").appendingPathExtension("plist")
            
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
    static func retrieveObject() -> [Notebook]? {
        
        // prepare path
        //        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let DocumentDirURL = CloudDataManager.shared.getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL.appendingPathComponent("notebooks-list").appendingPathExtension("plist")
        
        
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
