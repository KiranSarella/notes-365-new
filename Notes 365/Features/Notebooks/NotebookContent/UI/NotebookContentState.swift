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
class EditorOutputBuffer {
    static let shared = EditorOutputBuffer()
    
    var output: String = ""
    var selectedRange: NSRange = NSRange()
    var canUndo: Bool = false
    var canRedo: Bool = false
    
    func reset(_ input: String) {
        logger.debug("\(#function)")
        self.output = input
        selectedRange = NSRange()
        canUndo = false
        canRedo = false
    }
    
}

@Observable
class NotebookContentState {
    let business: NotebookContentRequester
    private(set) var notebookId: UUID = UUID()
    var isFetchingData = true
    var input: String = ""
    var fileName: String = ""
//    var output: String = ""
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
        logger.debug("\(#function)")
        do {
            input = try business.retrieveOrInstantiateNotebookContent(for: notebookId).notebookContent().content
            EditorOutputBuffer.shared.reset(input)
            lastSavedDate = DateTime.now()
        } catch let error {
            logger.error("\(error)")
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
        logger.debug("\(#function) - \(self.notebookId.uuidString)")
        do {
            try business.update(notebookContent: NotebookContentB(notebookID: notebookId, content: EditorOutputBuffer.shared.output))
            lastSavedDate = DateTime.now()
        } catch let error {
            logger.error("\(error)")
            fatalError(error.localizedDescription)
        }
    }
    
    
    func notifyNotebookOpen() {
        let info = [
            "notebook_id": notebookId,
            "name": fileName,
            "isFolder": false
        ] as [String : Any]
        
        let notification = Notification(name: .addToRecent, userInfo: info)
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
        
//        NotificationCenter.default.post(name: Notification.Name.addToRecent, object: nil, userInfo: info)
        logger.debug("\(#function) - \(info)")
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
