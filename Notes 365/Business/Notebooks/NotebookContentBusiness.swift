//
//  NotebookBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

class NotebookContentBusiness {
    
    static let shared = NotebookContentBusiness()
    
    private init() {
        
        
    }
    
    static func loadContent(selection: UserSelectionState) -> String {
        
        // read data from file
        guard let notebook = NotebooksListState.shared.getNotebook(levels: selection.selectedLevels, index: selection.selectedIndex) else { return "" }
        
        let folderPath = NotebooksListState.shared.getFolderNamesPath(levels: selection.selectedLevels)
        
//        print(folderPath, contentStr)
        
        return FilesHelper.shared.readFile(fileName: notebook.name, folderPath: folderPath) ?? ""
    }
    
    // diff
    static func getChanges(old: String, new: String) -> String {
        
        return StringDiff.getChanges(old: old, new: new)
    }
    
    
    
    // MARK: - base version
    
    static func createBaseVersion(for fileName: String, with content: String) {
        
        FilesHelper.shared.writeToFile(fileName: fileName, folderPath: "today_base_version", content: content)
    }
    
    static func isBaseVersionExists(fileName: String) -> Bool {
        let folderPath = "today_base_version"
        return FilesHelper.shared.fileExists(atPath: folderPath, fileName: fileName)
    }
    
    static func getBaseVersion(for fileName: String) -> String? {
        
        return FilesHelper.shared.readFile(fileName: fileName, folderPath: "today_base_version")
    }
    
    
    static func saveContentChanges(userSelectionState: UserSelectionState, txt: String) {
        
        
        // TODO: check date
        // if now == appear date; continue
        // else have to handle on appear process again; like - today_base_version..
        
        //        print(txt)
        
        //        // handle notebook not exists (notebook deleted case)
        //        if UsersState.shared.userSelectionState == nil {
        //            return
        //        }
        
        guard var notebook = NotebooksListState.shared.getNotebook(levels: userSelectionState.selectedLevels, index: userSelectionState.selectedIndex) else { return }
        notebook.content = txt
        
        // compare with snapshot version
        // base version will be created on appear, so assuming it will exists
        // but when we stay on same notebook while day changed, then?
        guard let baseVersion = NotebookContentBusiness.getBaseVersion(for: notebook.id.uuidString) else { return }
        
        // track changes using diff algs
        // get new changes
        let newContent = NotebookContentBusiness.getChanges(old: baseVersion, new: notebook.content)
        
        
        if newContent.count > 0 {
            // get / create Timeline object for a day
            
            let folderPath = NotebooksListState.shared.getFolderNamesPath(levels: userSelectionState.selectedLevels)
            
            VersionBusiness.shared.addOrUpdateToday(contentChanges: newContent, uuid: notebook.id, fileName: notebook.name, filePath: folderPath)
            
            
            // write data to file if modified
            FilesHelper.shared.writeToFile(fileName: notebook.name, folderPath: folderPath, content: notebook.content)
            
            //            print("------> saved to db ******")
        } else {
            //            print("content not edited *****")
        }
        
    }
}
