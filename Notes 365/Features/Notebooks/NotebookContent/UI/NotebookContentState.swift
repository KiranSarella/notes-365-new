//
//  NotebookEditorState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftUI
import Combine

@Observable
class NotebookContentState {
    let business: NotebookContentRequester
    private(set) var notebookId: UUID = UUID()
    var isFetchingData = true
    var input: String = ""
    var output: String = ""
    var contentEditedDate: Date? = DateTime.now()
    var lastSavedDate: Date = DateTime.now()
    @ObservationIgnored
    private var autoSaveTimer: Timer? = nil
    
    init(business: NotebookContentRequester) {
        self.business = business
    }
    
    deinit {
        invalidateAutoSaveTimer()
    }
    
    func loadContent(for notebookId: UUID) {
        self.notebookId = notebookId
        print(#function, notebookId.uuidString)
        do {
            input = try business.retrieveOrInstantiateNotebookContent(for: notebookId).notebookContent().content
            output = input
            lastSavedDate = DateTime.now()
        } catch let error {
            print(error)
            fatalError(error.localizedDescription)
        }
        self.isFetchingData = false
        self.contentEditedDate = nil
    }
    
    func saveChangesIfModified() {
        guard let contentEditedDate = contentEditedDate else { return }
        if contentEditedDate >= lastSavedDate {
            saveChanges()
        }
    }
    
    func saveChanges() {
        print(#function, notebookId.uuidString)
        do {
            try business.update(notebookContent: NotebookContentB(notebookID: notebookId, content: output))
            lastSavedDate = DateTime.now()
        } catch let error {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
    
}


extension NotebookContentState {
    
    func startAutoSaveTimer() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            self.saveChangesIfModified()
        }
    }
    
    func invalidateAutoSaveTimer() {
        autoSaveTimer?.invalidate()
    }
}

extension NotebookContentB {
    func notebookContent() -> NotebookContent {
        NotebookContent(notebookID: notebookID, content: content)
    }
}

extension NotebookContent {
    func notebookContentB() -> NotebookContentB {
        NotebookContentB(notebookID: notebookID, content: content)
    }
}
