//
//  MigrateOldData.swift
//  Notes 365
//
//  Created by kiran ipc on 05/12/23.
//

import Foundation

/*
 [x] notebooks
 [ ] timelines
 [ ] today versions
 */

class MigrationProcess {
    var basePathURL: URL
    
    var notebooksStorage = BusinessFactory.createNotebooksStorage()
    var noteContentStorage = BusinessFactory.createNotebookContentStorageProvider()
    
    init(basePathURL: URL) {
        self.basePathURL = basePathURL
    }

    func startMigrationProcess() async {
        await migrateNotebooks()
    }
    
    func migrateTimelines() {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Notebooks
    func migrateNotebooks() async {
        logger.debug("\(#function)")
        // get plist. and prepare
        guard let notebooks = retrieveNotebooks() else { return }
        logger.debug("notebooks count: \(notebooks.count)")
        // gather all info.
        // for each notebook prepare new notebook info.
        // get notebook content
        // if contains children mark as folder
        // create other file with same name inside that folder.
        await saveNotebooks(notebooks: notebooks)
        try? await Task.sleep(nanoseconds: 15_000_000_000)
    }
    
    func processNotebook(oldN: NotebookOld) async {
        if oldN.containChildNotebooks {
            await createFolderAndFile(for: oldN)
        } else {
            await createFile(for: oldN)
        }
        
        // children
        if oldN.containChildNotebooks {
            await saveNotebooks(notebooks: oldN.children!)
        }
    }
    
    func saveNotebooks(notebooks: [NotebookOld]) async {
        for oldN in notebooks {
            await processNotebook(oldN: oldN)
        }
    }
    
    func createFolderAndFile(for oldN: NotebookOld) async {
        logger.debug("\(#function), \(oldN.name)")
        // create folder and create file
        let newFolder = NotebookB(id: oldN.id, name: oldN.name)
        newFolder.isFolder = true
        newFolder.parentId = oldN.parent?.id
        try? notebooksStorage.insert(notebook: newFolder)
        
        if let content = await oldN.loadContent() {
            logger.debug("\(#function), \(oldN.name)")
            // new file inside folder
            let newFile = NotebookB(id: oldN.id, name: oldN.name)
            newFile.isFolder = false
            newFile.parentId = oldN.id
            try? notebooksStorage.insert(notebook: newFile)
            // insert content
            let noteContent = NotebookContentB(notebookID: newFile.id, content: content)
            try? noteContentStorage.insert(notebookContent: noteContent)
        }
    }
    
    func createFile(for oldN: NotebookOld) async {
        // create file inside folder if contents exists
        if let content = await oldN.loadContent() {
            logger.debug("\(#function), \(oldN.name)")
            // new file inside folder
            let newFile = NotebookB(id: oldN.id, name: oldN.name)
            newFile.isFolder = false
            newFile.parentId = oldN.parent?.id
            try? notebooksStorage.insert(notebook: newFile)
            // insert content
            let noteContent = NotebookContentB(notebookID: newFile.id, content: content)
            try? noteContentStorage.insert(notebookContent: noteContent)
        }
    }
    
    // retrives notebooks hierarcy from plist, not the notebook content.
    func retrieveNotebooks() -> [NotebookOld]? {
        logger.debug("\(#function)")
       let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")
       do {
           // Read the file contents
           let plistData = try Data(contentsOf: plistURL)
           let notebooksList = try PropertyListDecoder().decode([NotebookOld].self, from: plistData)
           return notebooksList
       } catch let error as NSError {
           print("Failed reading from URL: \(plistURL), Error: " + error.localizedDescription)
       }
       return nil
    }
    
}
