//
//  MarkdownEditorViewState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/05/23.
//

import Foundation

extension Notification.Name {
    public static let notebookRenamed = Notification.Name("com.notes365.notebookRenamed")
}

class MarkdownEditorViewState: ObservableObject {
    
    @Published var fileName: String = ""
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(notebookNameChanged(_:)), name: .notebookRenamed, object: nil)
    }
    
    @objc func notebookNameChanged(_ notification: NSNotification) {
        print(#function)
        guard let userInfo = notification.userInfo as? [String: String] else { return }
        if let name = userInfo["name"] {
            fileName = name
        }
    }
}
