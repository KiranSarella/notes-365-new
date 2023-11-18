//
//  NotebooksPresenter.swift
//  Notes 365
//
//  Created by kiran ipc on 13/11/23.
//

import Foundation
import SwiftUI

class NotebooksPresenter {
    
    var viewModel: NotebooksViewModel
    
    init() {
        viewModel = NotebooksViewModel(text: "empty")
    }
    
    func handleValidationResponse(data: String) {
        viewModel.isValid = true
    }
    
    func showNotebooksList(notebooksH: Notebook?) {
        // convert business layer objects to view layer objects
        if let notebooksH = notebooksH {
            var notebookVM = NotebookVM(notebook: notebooksH)
            
            if let childNotes =  notebooksH.children {
                for child in childNotes {
                    let c = NotebookVM(notebook: child)
                    c.updateParent(notebookVM)
                    notebookVM.appendChildren(notebook: c)
                }
            }
            
        } else {
            viewModel.isNotebooksExists = false
        }
    }
    
//    func createNotebooksViewModel() -> NotebooksViewModel {
//        
//        return NotebooksViewModel()
//    }
    
    
//    func createView() -> some View {
//        
//        return NotebooksUI(viewModel: viewModel)
//    }
    
}


extension NotebookVM {
    
    convenience init(notebook: Notebook) {
        self.init(id: notebook.id, name: notebook.name)
        createdDate = notebook.createdDate
        modifiedDate = notebook.modifiedDate
        deletedDate = notebook.deletedDate
    }
    
    func getVM(from: Notebook) {
        
    }
    
}
