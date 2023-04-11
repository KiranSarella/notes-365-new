//
//  NotebookEditorState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftUI
import Combine

//@MainActor
class NotebookEditorState: ObservableObject {
    
    var notebookBusiness: NotebookContentBusiness?
    
    @Published var isFetchingData = true
    @Published var baseContent: String = ""
    @Published var editorType = EditorType.smart
    @Published var theme: MarkdownTheme
    @Published var showSymbols = false
//    var contentEdited = false
    var contentEditedDate: Date? = Date()
    var lastSavedDate: Date = Date()
    var baseVersionCreated = false
    @Published var versionDate: Date = Date()
    
    unowned private(set) var notebook: Notebook!
    
    var getNotebook: (()->(Notebook?))?
    
    var getNewContent: (() async -> (String))? = nil
    
    
    
//    let autoSaveTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // 1 min
    
    var cancellableTheme: Cancellable!
    var cancellableTimer: Cancellable?
    
    init() {
        
        theme = ThemeState.shared.theme
        observeThemeChanges()
    }
    
    func observeThemeChanges() {
        cancellableTheme = ThemeState.shared.$theme
            .receive(on: DispatchQueue.main)
            .sink { newTheme in
                self.theme = newTheme!
            }
    }
    
    func setupNewNotebook() {
        
        self.notebook = notebook
        self.notebookBusiness = NotebookContentBusiness(notebook: self.notebook)
    }
    
    @MainActor
    func loadContent(for notebook: Notebook) async {
        self.isFetchingData = true
        let content = await self.notebook.loadContent() ?? ""
        self.baseContent = content
        self.isFetchingData = false
        self.contentEditedDate = nil
    }
    
    func configBaseVersionIfNecessary(_ notebook: Notebook) {
        // reset base version folder on date changed
        VersionBusiness.resetBaseVersionIfNeeded()
        // if reset done, then recreate baseversion file
        if VersionBusiness.isBaseVersionExists(fileName: notebook.id.uuidString) == false {
            // case 1: for new notes
            // case 2: for existing notes
            VersionBusiness.createBaseVersion(for: notebook.id.uuidString, with: self.baseContent)
            baseVersionCreated = true
        } else {
            baseVersionCreated = true
        }
    }
    
    
    
    func saveContentChanges() async {
//        print("saveContentChanges")
//        if self.notebook != nil {
//            if self.notebook.document?.documentState == .progressAvailable
//                || self.notebook.document?.documentState == .editingDisabled {
//                print("return due to: \(self.notebook.document?.documentState)")
//                return
//            }
//        }
        guard let contentEditedDate = contentEditedDate else { return }
//        print("contentEditedDate: \(contentEditedDate)")
//        print("last savedDate: \(lastSavedDate)")
        if contentEditedDate >= lastSavedDate {
            
//            contentEdited = false
            if let txt = await self.getNewContent?() {
                
//                notebookBusiness?.saveContentChanges(content: txt)
//                self.lastSavedDate = Date()
                
                if versionDate.isSameDayAs(Date.now) && baseVersionCreated {
//                    print("IN SAME DAY")
                    // same day
                    lastSavedDate = Date()
                    notebookBusiness?.saveContentChanges(content: txt)
                } else {
                    // ** day changed **
                    // reset baseContent
//                    print("DAY CHANGED")
//                    DispatchQueue.main.async {
//                        Task {
                            await self.loadContent(for: self.notebook)
                            // create new baseversion
                            self.configBaseVersionIfNecessary(self.notebook)
                            // update version date
                            self.versionDate = Date()
                            // now save content
                            self.lastSavedDate = Date()
                            self.notebookBusiness?.saveContentChanges(content: txt)
//                            await self.notebook.saveDocument(with: txt)
//                        }
//                    }
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
