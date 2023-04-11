//
//  NotebookBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

/*
 
 purpose: notebook + timeline handling
 
 */


class NotebookContentBusiness {
    
    static let notebooksPath = Constants.notebooksFolderName
    static let baseVersionPath = Constants.todayBaseVersionFolderName
    
    func saveContentChanges(content: String, notebook: Notebook) {
//        print(#function)
//        cloudService.updateUpdateDate()
        
        // if now == appear date; continue
        // else have to handle on appear process again; like - today_base_version..
        
        // compare with snapshot version
        // base version will be created on appear, so assuming it will exists
        // but when we stay on same notebook while day changed, then?
        guard
            let baseVersion = VersionBusiness.getBaseVersion(for: notebook.id.uuidString)
        else { return }
        
        // track changes using diff algs
        // get new changes
        let newContent = StringDiff.getChanges(old: baseVersion, new: content)
        
        // 1. update today version content
        // 2. update notebook content
        if newContent.count > 0 {
            // get / create Timeline object for a day
            // update version
            VersionBusiness.shared.addOrUpdateToday(contentChanges: newContent, uuid: notebook.id, fileName: notebook.name, filePath: notebook.folderPath)
            // update notebook
            
//            Task {
//                print("SAVING CONTENT:")
//                print(content)
//                await notebook.saveDocument(with: content)
//            }
            
            notebook.saveContent(content: content)
        } else {
//            print("content not edited *****")
        }
    
    }
}
