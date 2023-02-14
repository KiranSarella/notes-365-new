//
//  NotebookEditorState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class NotebookEditorState: ObservableObject {
    
    let notebookBusiness = NotebookContentBusiness.shared
    @Published var isFetchingData = true
    @Published var baseContent: String = ""
    @Published var editorType = EditorType.smart
    @Published var theme: MarkdownTheme
    @Published var showSymbols = false
    @Published var contentEdited = false
    @Published var versionDate: Date = Date()
    
    unowned var notebook: Notebook!
    
    var getNotebook: (()->(Notebook?))?
    
    var getNewContent: (()->(String))? = nil
    
//    let autoSaveTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // 1 min
    
    var cancellableTheme: Cancellable!
    var cancellableTimer: Cancellable?
    
    init() {
        theme = ThemeState.shared.theme
        observeThemeChanges()
//        observeAutoSaveTimer()
    }
    
    func observeThemeChanges() {
        cancellableTheme = ThemeState.shared.$theme
            .receive(on: DispatchQueue.main)
            .sink { newTheme in
                self.theme = newTheme!
            }
    }
    
    func loadContent() async {
        baseContent = ""
        isFetchingData = true
//        self.baseContent = notebook.loadContent()
        
        self.baseContent = await notebook.readDocument() ?? ""
        
        isFetchingData = false
        contentEdited = false
    }
    
//    func loadContent(notebookInfo: SelectedNotebookInfo) {
//
//        contentStr = ""
//
//        txt = ""
//
//        isFetchingData = true
//
//        self.contentStr = NotebookContentBusiness.loadContent(selection: notebookInfo)
//        self.txt = self.contentStr
//
//        isFetchingData = false
//    }
    
    // diff
    func getChanges(old: String, new: String) -> String {
        return NotebookContentBusiness.getChanges(old: old, new: new)
    }
    
    func setBaseVersion(_ notebook: Notebook) {
        // reset base version folder on date changed
        VersionBusiness.resetBaseVersionIfNeeded()
        // if reset done, then recreate baseversion file
        if NotebookContentBusiness.isBaseVersionExists(fileName: notebook.id.uuidString) == false {
            // case 1: for new notes
            // case 2: for existing notes
            NotebookContentBusiness.createBaseVersion(for: notebook.id.uuidString, with: self.baseContent)
        }
    }
    
    func saveContentChanges() {
        if contentEdited {
            if let txt = self.getNewContent?() {
                
                if versionDate.isSameDayAs(Date.now) {
                    // same day
                    NotebookContentBusiness.saveContentChanges(notebook: notebook, content: txt)
                } else {
                    // ** day changed **
                    // reset baseContent
                    
                    DispatchQueue.main.async {
                        Task {
                            await self.loadContent()
                            // create new baseversion
                            self.setBaseVersion(self.notebook)
                            // update version date
                            self.versionDate = Date()
                            // now save content
                            await self.notebook.saveDocument(with: txt)
                        }
                    }
                }
                
//                // TODO: check date
//                if !appearDate.isSameDayAs(Date.now) {
//                    // means - system date changed.
//                    // delete existing base version content
//                    VersionBusiness.cleanOldBaseVersions()
//                    // create new base verion
//                    createBaseVersion(for: <#T##String#>, with: <#T##String#>)
//                    // notify changes
//                    onVersionChange()
//                }
                
            }
        }
    }
    
}
