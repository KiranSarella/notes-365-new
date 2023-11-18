//
//  NotebooksViewModel.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

class NotebooksViewModel {
    
    var isNotebooksExists = false
    var isValid = false
    var text: String = "sample text **bold**"
    
    var notebookH: NotebookVM!
    
    init(text: String) {
        self.text = text
    }
    
    
//    init(presenter: NotebooksPresenter) {
//        self.presenter = presenter
//    }
}
