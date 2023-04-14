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
        // write updated content to file
        notebook.saveContent(content: content)
        // send notification
        // TODO: send notification after some delay - based on result.
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
