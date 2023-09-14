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
@Observable
class NotebookEditorState {
    
    var notebookBusiness = NotebookContentBusiness()
    
    var isFetchingData = true
    var baseContent: String = ""
    var theme: MarkdownTheme = ThemeState.shared.theme
    
    var contentEditedDate: Date? = Date()
    var lastSavedDate: Date = Date()
    
    @ObservationIgnored
    unowned private(set) var notebook: Notebook! = nil
    
//    var getNotebook: (()->(Notebook?))?
    var getNewContent: (() async -> (String))? = nil
    var getTextHandler:(() -> String)? = nil
    
    @ObservationIgnored
    var cancellableTheme: Cancellable? = nil
    @ObservationIgnored
    var cancellableTimer: Cancellable? = nil
    
    init() {
        theme = ThemeState.shared.theme
        observeThemeChanges()
    }
    
    func observeThemeChanges() {
//        cancellableTheme = ThemeState.shared.$theme
//            .receive(on: DispatchQueue.main)
//            .sink { newTheme in
//                self.theme = newTheme!
//            }
    }
    
    func setupNewNotebook(_ notebook: Notebook) {
        self.notebook = notebook
    }
    
    @MainActor
    func loadContent(for notebook: Notebook) async {
        setupNewNotebook(notebook)
        self.isFetchingData = true
        let content = await self.notebook.loadContent() ?? ""
        self.baseContent = content
        self.isFetchingData = false
        self.contentEditedDate = nil
        // send notebook Content Loaded notification
        let info = ["id": notebook.id.uuidString]
        NotificationCenter.default.post(name: Notification.Name.notebookContentLoaded, object: nil, userInfo: info)
    }
    
    func saveContentChanges() async {
        // ignore autosave if content was not edited
        guard let contentEditedDate = contentEditedDate else { return }
        if contentEditedDate >= lastSavedDate {
            // get new content
            if let txt = await self.getNewContent?() {
                // set check date
                lastSavedDate = Date()
                // save content to file
                notebookBusiness.saveContentChanges(content: txt, notebook: notebook)
            }
        }
    }
    
}
