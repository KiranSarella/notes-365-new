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
    
    let notebooksStorage = BusinessFactory.createNotebooksStorage()
    let noteContentStorage = BusinessFactory.createNotebookContentStorageProvider()
    let timelineBusiness = TimelineBusinessOld(path: EnvironmentState.shared.basePathURL)
    let timelineStorage = BusinessFactory.createTimelineStorageProvider()
    
    init(basePathURL: URL) {
        self.basePathURL = basePathURL
    }

    func startMigrationProcess() async {
        await migrateTimelines()
        await migrateNotebooks()
    }
    
    func migrateTimelines() async {
        for await val in MonthContentGenerator(year: 2022) {
            logger.debug("\(val)")
        }
        for await val in MonthContentGenerator(year: 2023) {
            logger.debug("\(val)")
        }
        try? await Task.sleep(nanoseconds: 10_000_000_000)
    }
    
//    func constructMonthTimeline(month: Int, year: Int) async {
//        // if folder contain,
//        
//    }
    
//    func saveDayData(dayDate: DayDate) async {
//        guard let metadata = timelineBusiness.readDayMetaData(dayDate: dayDate) else {
//            return
//        }
//        let lines = metadata.components(separatedBy: "\n")
//        for await timelineB in DayContentGenerator(lines: lines, today: dayDate.date) {
//            try? timelineStorage.save(dayNotebookChange: timelineB)
//        }
//    }
    
    
    
    
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
