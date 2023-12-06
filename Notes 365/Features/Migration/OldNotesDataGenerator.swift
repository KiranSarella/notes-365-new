//
//  WeekContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation

struct NotebookFolderFile {
    let folder: NotebookB
    let notebookFile: NotebookFile?
}

struct NotebookFile {
    let file: NotebookB
    let fileContent: NotebookContentB
}

struct NotebookArchive {
    let notebookOld: NotebookOld
    let folderAndFile: NotebookFolderFile?
    let file: NotebookFile?
}

struct OldNotesDataGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = NotebookArchive
    var weekDatesIterator: IndexingIterator<[NotebookOld]>
    
    init(oldNotes: [NotebookOld]) {
        weekDatesIterator = oldNotes.makeIterator()
    }
    
    mutating func next() async -> Element? {
        if Task.isCancelled {
            return nil
        }
        if let dayChanges = weekDatesIterator.next() {
            return await fetchDayMetadata(for: dayChanges)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> OldNotesDataGenerator {
        self
    }
    
    func fetchDayMetadata(for oldNote: NotebookOld) async -> NotebookArchive? {
        let folderFile = await createFolderAndFile(for: oldNote)
        let file = await createFile(for: oldNote)
       
        return NotebookArchive(notebookOld: oldNote, folderAndFile: folderFile, file: file)
    }
    
    func createFolderAndFile(for oldN: NotebookOld) async -> NotebookFolderFile? {
        if oldN.containChildNotebooks == false {
            return nil
        }
        logger.debug("\(#function), \(oldN.name)")
        // create folder and create file
        let newFolder = NotebookB(id: oldN.id, name: oldN.name)
        newFolder.isFolder = true
        newFolder.parentId = oldN.parent?.id
        
        return NotebookFolderFile(folder: newFolder, notebookFile: nil)
        
//        if let content = await oldN.loadContent() {
//            logger.debug("\(#function), \(oldN.name)")
//            // new file inside folder
//            let newFile = NotebookB(id: oldN.id, name: oldN.name)
//            newFile.isFolder = false
//            newFile.parentId = oldN.id
//            
//            // insert content
//            let noteContent = NotebookContentB(notebookID: newFile.id, content: content)
//            return NotebookFolderFile(folder: newFolder, notebookFile: NotebookFile(file: newFile, fileContent: noteContent))
//        } else {
//            
//        }
    }
    
    func createFile(for oldN: NotebookOld) async -> NotebookFile? {
        // create file inside folder if contents exists
        if let content = await oldN.loadContent() {
            logger.debug("\(#function), \(oldN.name)")
            // new file inside folder
            let newFile = NotebookB(id: oldN.id, name: oldN.name)
            newFile.isFolder = false
            newFile.parentId = oldN.parent?.id
            // insert content
            let noteContent = NotebookContentB(notebookID: newFile.id, content: content)
            return NotebookFile(file: newFile, fileContent: noteContent)
        }
        return nil
    }
}
