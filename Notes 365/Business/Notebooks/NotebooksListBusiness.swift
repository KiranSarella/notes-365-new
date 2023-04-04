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
    
//    static let shared = NotebooksListBusiness(dataManager: DataManager(environment: .cloud))
    
    private static var _shared: NotebooksListBusiness!
    
    var basePathURL: URL
    
    var dataManager: DataManager!
    
//    var document: PlistDocument?
//    var newContentAvailalble: (()->())?
//    private var notificationObserver: Any?
//    var isResolvingConflicts = false
//
    var notebooks: [Notebook]
    
    
    
//    var notebooksHashMap = [UUID: Notebook]()
    
//    private let notebooksLimit = 3
    
    let notebooksPath = Constants.notebooksFolderName
    
//    let cloudService = CloudService(cloudDirectory: "Documents", cloudSyncFileName: "notebooks-list.plist")
    
    static func shared(path basePath: URL) -> NotebooksListBusiness {
        if _shared == nil {
            _shared = NotebooksListBusiness(basePath)
        }
        return _shared
    }
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
        
        self.dataManager = DataManager(path: basePathURL)
        // no notebooks exists, create empty or base configuration
        self.notebooks = [Notebook]()
        
        if let notebooks = retrieveNotebooks() {
            self.notebooks = notebooks
        }
        
        // if new folder not exits and contains notebooks - means old version structure
//        let flatNotebooksPath = dataManager.basePathURL.appendingPathComponent(notebooksPath).path(percentEncoded: false)
//        if !FileManager.default.fileExists(atPath: flatNotebooksPath) && notebooks.count > 0 {
//            convertToFlatStructure()
//        }

        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangeNotification(_:)), name: .notebookChangeNotification, object: nil)
        
        // generate hash map
//        generateNotebooksHashMap()
    }
    
//    @objc func handleNotebookChangeNotification(_ sender: Notification) {
//        print(#function)
//    }
    
//    func generateNotebooksHashMap() {#imageLiteral(resourceName: "simulator_screenshot_899493EC-342E-4D8C-A23B-D930A1022ECD.png")
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

        print(#function)
        
        func traverse(notebooks: [Notebook]) {
            // traverse and add each item to hash map
            for notebook in notebooks {
                // move to base folder
                
                let oldFolderPath = dataManager.basePathURL.appendingPathComponent(Constants.notebooksFolderNameOld).appendingPathComponent(notebook.oldFilePath)
                let newFolderPath = dataManager.basePathURL.appendingPathComponent(notebooksPath).appendingPathComponent(notebook.id.uuidString).appendingPathExtension("md")
                
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
        let newFolderPath = dataManager.basePathURL.appendingPathComponent(notebooksPath)
        try? FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true)
        // start traversing
        traverse(notebooks: notebooks)
        
        // for each item
        // get its path
        // move to /notebooks with id.md
        
    }
    
    func reloadNotebooksList(completion:()->()) {
        self.notebooks = [Notebook]()
        
        if let notebooks = retrieveNotebooks() {
            self.notebooks = notebooks
            completion()
        } else {
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
        if !dataManager.itemExists(atPath: notebooksPath) {
            // create notebooks folder
            // create timeline folder
            // create base/dummy notebook (for consistent top and later level implementations)
            
            dataManager.createFolder(Constants.notebooksFolderName)
            dataManager.createFolder(Constants.timelineFolderName)
            dataManager.createFolder(Constants.todayBaseVersionFolderName)
        }
    }
    
    func observeFileChanges() {
        
        
    }
    
    // MARK: - Insert
    func addFirstNotes() -> Notebook {
        
        createRequiredFoldersIfNotExists()
        
        // create first notebook inside "/notesbooks"
        let firstBook = createNotebook(parent: nil)
        notebooks.append(firstBook)
        // persist content
        dataManager.writeToFile(content: "", fileName: firstBook.id.uuidString, folderPath: notebooksPath, ext: "md")
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
            dataManager.writeToFile(content: "", fileName: newNotebook.id.uuidString, folderPath: fullPath, ext: "md")
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
        let filePath = notebooksPath + "/" + notebook.id.uuidString + ".md"
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

        return notebooksPath
//
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
        
        dataManager.persistNotebooks(notebooks)
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

/*
// MARK: - UIDocument operations
extension NotebooksListBusiness {
    
    func readDocument() async -> [Notebook]? {
        print(#function)
        let plistURL = basePathURL.appending(path: Constants.notebooksListPath).appendingPathExtension("plist")
        document = await PlistDocument(fileURL: plistURL)
        guard let document = document else { return nil }
        let isOpened = await document.open()
        if isOpened {

        } else {
            print("Failed to open the file \(plistURL.path(percentEncoded: false))")
        }
        await print(document.documentState)
        registerDocumentChangeNotification()
        observeContentChanges()
        let plistData = await document.content
        do {
            // Read the file contents
            let notebooksList = try PropertyListDecoder().decode([Notebook].self, from: plistData)
            
            self.notebooks = notebooksList
            
            return notebooksList
        } catch let error as NSError {
            print("Decode Error: " + error.localizedDescription)
        }
        return nil
    }


//    func updateDocument(with content: String) {
//        guard let document = document else { return }
//        document.updateChangeCount(.done)
//    }

    func saveDocument(with content: [Notebook]) async {
        print(#function)
        guard let document = document else { return }
        do {
            let plistData = try PropertyListEncoder().encode(content)
            await document.setContentChanges(newContent: plistData)
            await document.updateChangeCount(.done)
        } catch let error {
            print(error)
        }
    }

    func closeDocument() async {
        print(#function)
        self.removeContentChangesObserver()
        self.removeDocumentChangeNotification()

        //        guard let document = document else { return }
        await document?.close()
        self.removeDocumentChangeNotification()
        document = nil
    }


    // MARK: - Document Notfications
    func observeContentChanges() {
        document?.newContentAvailalble = {
            print("document?.newContentAvailalble")
            Task {
                guard let document = self.document else { return }
                let plistData = await document.content
                do {
                    // Read the file contents
                    let notebooksList = try PropertyListDecoder().decode([Notebook].self, from: plistData)
                    self.notebooks = notebooksList
                } catch let error as NSError {
                    print("decode Error: " + error.localizedDescription)
                }
                self.newContentAvailalble?()
            }
        }
    }

    func removeContentChangesObserver() {
        document?.newContentAvailalble = nil
    }


    func registerDocumentChangeNotification() {

        guard let document = document else { return }

        notificationObserver = NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: document, queue: nil) { notification in

            print("UIDocument.stateChangedNotification")
            print(document.documentState)


            //            if document.documentState == UIDocument.State.progressAvailable
            //                || document.documentState == UIDocument.State.editingDisabled
            //                || document.documentState == UIDocument.State.normal {
            //
            //                self.newContentAvailalble?()
            //            }
            //

            if document.documentState == UIDocument.State.inConflict {
                if self.isResolvingConflicts {
                    return
                }

                self.isResolvingConflicts = true
                if let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItem(at: self.basePathURL) {
                    print(conflictVersions.count)

                    do {
                        let success = try NSFileVersion.removeOtherVersionsOfItem(at:  self.basePathURL)

                    } catch let error as NSError {
                        print(error)
                    }

                    for i in 0..<conflictVersions.count {
                        conflictVersions[i].isResolved = true
                    }
                }
                self.isResolvingConflicts = false
            }
        }

    }

    func removeDocumentChangeNotification() {
        print(#function)
        if let notificationObserver = notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver, name: UIDocument.stateChangedNotification, object: document)
        }

    }
}


*/
