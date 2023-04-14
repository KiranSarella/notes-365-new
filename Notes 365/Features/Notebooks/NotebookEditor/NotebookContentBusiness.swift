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
    
    /*
    func saveContentChanges(content: String, notebook: Notebook) {
//        print(#function)
//        cloudService.updateUpdateDate()
        
        // if now == appear date; continue
        // else have to handle on appear process again; like - today_base_version..
        
        // compare with snapshot version
        // base version will be created on appear, so assuming it will exists
        // but when we stay on same notebook while day changed, then?
        guard
            let baseVersion = TodayVersionBusiness.getBaseVersion(for: notebook.id.uuidString)
        else { return }
        
        // track changes using diff algs
        // get new changes
        let newContent = StringDiff.getChanges(old: baseVersion, new: content)
        
        // 1. update today version content
        // 2. update notebook content
        if newContent.count > 0 {
            // get / create Timeline object for a day
            // update version
//            TodayVersionBusiness.shared.addOrUpdateToday(contentChanges: newContent, uuid: notebook.id, fileName: notebook.name, filePath: notebook.folderPath)
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
    */
    
    
    func saveContentChanges(content: String, notebook: Notebook) {
        
        notebook.saveContent(content: content)
        
        // if required - send notification after some delay
        let info = [
            "id": notebook.id.uuidString,
            "notebookName": notebook.name,
            "notebookPath": notebook.folderPath
        ]
        NotificationCenter.default.post(name: Notification.Name.notebookContentUpdated, object: nil, userInfo: info)
    }
    
    
    static func loadContent(id: String) async -> String? {
        
        let filePath = id + ".md"
        
        var fileURL: URL {
            let path = Constants.notebooksFolderName + "/" + filePath
            let basePathUrl = EnvironmentState.shared.basePathURL!
            let fileURL = basePathUrl.appendingPathComponent(path)
            //        print(fileURL)
            return fileURL
        }
        
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            guard
                let data = try fileHandle.readToEnd(),
                let readString = String(data: data, encoding: .utf8) else { return nil }
            
            fileHandle.closeFile()
            return readString
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
}
