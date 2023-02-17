//
//  NotebookBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

class NotebookContentBusiness {
    
    static let shared = NotebookContentBusiness()
    
    static let notebooksPath = Constants.notebooksPath
    static let baseVersionPath = Constants.baseVersionPath
    
    private init() {
        
    }

    // diff
    static func getChanges(old: String, new: String) -> String {
        return StringDiff.getChanges(old: old, new: new)
    }
    
    // MARK: - base version
    static func createBaseVersion(for fileName: String, with content: String) {
        
        FilesHelper.shared.writeToFile(fileName: fileName, folderPath: baseVersionPath, content: content)
    }
    
    static func isBaseVersionExists(fileName: String) -> Bool {
        return FilesHelper.shared.fileExists(atPath: baseVersionPath, fileName: fileName)
    }
    
    static func getBaseVersion(for fileName: String) -> String? {
        return FilesHelper.shared.readFile(fileName: fileName, folderPath: baseVersionPath)
    }
    
    static func saveContentChanges(notebook: Notebook, content: String) {
       
        // if now == appear date; continue
        // else have to handle on appear process again; like - today_base_version..
        
        // compare with snapshot version
        // base version will be created on appear, so assuming it will exists
        // but when we stay on same notebook while day changed, then?
        guard
            let baseVersion = NotebookContentBusiness.getBaseVersion(for: notebook.id.uuidString)
        else { return }
        
        // track changes using diff algs
        // get new changes
        let newContent = NotebookContentBusiness.getChanges(old: baseVersion, new: content)
        
        // 1. update today version content
        // 2. update notebook content
        if newContent.count > 0 {
            // get / create Timeline object for a day
            // update version
            VersionBusiness.shared.addOrUpdateToday(contentChanges: newContent, uuid: notebook.id, fileName: notebook.name, filePath: notebook.folderPath)
            // update notebook
            
            Task {
                await notebook.saveDocument(with: content)
            }
            
//            FilesHelper.shared.writeToFile(path: notebooksPath + "/" + notebook.filePath, content: content)
//            print("------> saved to db ******")
        } else {
//            print("content not edited *****")
        }
    
    }
}
