//
//  MigrateOldData.swift
//  Notes 365
//
//  Created by kiran ipc on 05/12/23.
//

import Foundation

/*
 [x] notebooks
 [x] timelines
 [ ] today versions
 */

class MigrationProcess {
    var basePathURL: URL
    
    let notebooksStorage = BusinessFactory.createNotebooksStorage()
    let noteContentStorage = BusinessFactory.createNotebookContentStorageProvider()
    let timelineBusiness = TimelineBusinessOld(path: EnvironmentState.shared.basePathURL)
    let timelineStorage = BusinessFactory.createTimelineStorageProvider()
    
    init(basePathURL: URL) {
        self.basePathURL = basePathURL
    }

    func startMigrationProcess() async {
        logger.info("\(#function)")
        // check if plist exits
        let plistURL = basePathURL.appending(path: Constants.notebooksPListName).appendingPathExtension("plist")
        if FileManager.default.fileExists(atPath: plistURL.path) == false {
            UserDefaults.standard.set(true, forKey: "migration_check_status")
            return
        }
        await migrateTimelines()
        await migrateNotebooks()
        // save status in userdefaults
        UserDefaults.standard.set(true, forKey: "migration_check_status")
    }
    
    
//    func migrateDayVersions() async {
//        // only current day
//        
//    }
    
    
    // MARK: - Timelines
    func migrateTimelines() async {
        logger.info("\(#function)")
        for await val in MonthContentGenerator(year: 2022) {
            logger.debug("\(val)")
        }
        for await val in MonthContentGenerator(year: 2023) {
            logger.debug("\(val)")
        }
        try? await Task.sleep(nanoseconds: 10_000_000_000)
    }
    
    // MARK: - Notebooks
    func migrateNotebooks() async {
        logger.info("\(#function)")
        logger.debug("\(#function)")
        // get plist. and prepare
        guard let notebooks = retrieveNotebooks() else { return }
        logger.debug("notebooks count: \(notebooks.count)")
        // gather all info.
        // for each notebook prepare new notebook info.
        // get notebook content
        // if contains children mark as folder
        // create other file with same name inside that folder.
        await saveNotebooks(oldNotes: notebooks)
        try? await Task.sleep(nanoseconds: 10_000_000_000)
    }
    
    func processNotebook(noteArch: NotebookArchive) async {
        // folder
        if let folderAndFile = noteArch.folderAndFile {
            try? notebooksStorage.insert(notebook: folderAndFile.folder)
        }
        // file
        if let notebookFile = noteArch.file {
            try? notebooksStorage.insert(notebook: notebookFile.file)
            try? noteContentStorage.insert(notebookContent: notebookFile.fileContent)
        }
        // children
        if noteArch.notebookOld.containChildNotebooks {
            await saveNotebooks(oldNotes: noteArch.notebookOld.children!)
        }
    }
    
    func saveNotebooks(oldNotes: [NotebookOld]) async {
        let oldNotesDataGenerator = OldNotesDataGenerator(oldNotes: oldNotes)
        for await noteArch in oldNotesDataGenerator {
            // perform save
            await processNotebook(noteArch: noteArch)
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
