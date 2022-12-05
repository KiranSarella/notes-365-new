//
//  NotebookEditorState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftUI
import Combine

class NotebookEditorState: ObservableObject {
    
    let notebookBusiness = NotebookContentBusiness.shared
    @Published var isFetchingData = true
    @Published var contentStr: String = ""
    @Published var txt: String = ""
    @Published var editorType = EditorType.smart
    @Published var theme: MarkdownTheme
    @Published var showSymbols = false
    @Published var contentEdited = false
    
    unowned var notebook: Notebook!
    
    var getNotebook: (()->(Notebook?))?
    
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
    
//    func observeAutoSaveTimer() {
//        cancellableTimer = Timer.publish(every: 60, on: .main, in: .common) // 1 min
//            .autoconnect()
//            .sink() {
//                print ("timer fired: \($0)")
//                self.saveContentChanges()
////                if let notebook = self.getNotebook?() {
////                    self.saveContentChanges(notebook: notebook)
////                }
//            }
//    }
    
    func loadContent() {
        
        contentStr = ""
        txt = ""
        isFetchingData = true
        self.contentStr = notebook.loadContent()
        self.txt = self.contentStr
        isFetchingData = false
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
        
        VersionBusiness.cleanOldBaseVersions()
        
        if NotebookContentBusiness.isBaseVersionExists(fileName: notebook.id.uuidString) == false {
            
            // case 1: for new notes
            // case 2: for existing notes
            NotebookContentBusiness.createBaseVersion(for: notebook.id.uuidString, with: self.contentStr)
        }
    }
    
    func saveContentChanges() {
//        print(#function, "########")
        if contentEdited {
            NotebookContentBusiness.saveContentChanges(notebook: notebook, content: txt)
        }
    }
    
}
