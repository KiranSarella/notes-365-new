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
    
    var notebookBusiness: NotebookContentBusiness?
    
    @Published var isFetchingData = true
    @Published var baseContent: String = ""
    @Published var editorType = EditorType.smart
    @Published var theme: MarkdownTheme
    @Published var showSymbols = false
    var contentEdited = false
    var contentEditedDate: Date? = Date()
    var lastSavedDate: Date = Date()
    @Published var versionDate: Date = Date()
    
    unowned private(set) var notebook: Notebook!
    
    var getNotebook: (()->(Notebook?))?
    
    var getNewContent: (()->(String))? = nil
    
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
    
    func loadContent(for notebook: Notebook) async {
        print("##Note-loadContent")
        self.notebook = notebook
        notebookBusiness = NotebookContentBusiness(notebook: notebook)
//        notebookBusiness?.cloudContentDidUpdate = { [weak self] newContent in
//            DispatchQueue.main.async {
//                self?.baseContent = newContent
//            }
//        }
        
        self.notebook.newContentAvailalble = { [weak self] in
            print("newContentAvailalble called")
            if let content = self?.notebook.document?.content {
                DispatchQueue.main.async {
                    self?.baseContent = content
                }
            }
        }
        
        
        baseContent = ""
        isFetchingData = true
//        self.baseContent = notebook.loadContent()
        
        self.baseContent = await notebook.readDocument() ?? ""
        
        isFetchingData = false
        contentEdited = false
        contentEditedDate = nil
    }
    
    
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
        
        if self.notebook != nil {
            if self.notebook.document?.documentState == .progressAvailable
                || self.notebook.document?.documentState == .editingDisabled {
                return
            }
        }
        print("contentEdited: \(contentEdited)")
        
        guard let contentEditedDate = contentEditedDate else { return }
        if contentEditedDate >= lastSavedDate {
//            contentEdited = false
            if let txt = self.getNewContent?() {
                
                if versionDate.isSameDayAs(Date.now) {
                    // same day
                    lastSavedDate = Date()
                    notebookBusiness?.saveContentChanges(content: txt)
                } else {
                    // ** day changed **
                    // reset baseContent
                    
                    DispatchQueue.main.async {
                        Task {
                            await self.loadContent(for: self.notebook)
                            // create new baseversion
                            self.setBaseVersion(self.notebook)
                            // update version date
                            self.versionDate = Date()
                            // now save content
                            self.lastSavedDate = Date()
                            self.notebookBusiness?.saveContentChanges(content: txt)
//                            await self.notebook.saveDocument(with: txt)
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
