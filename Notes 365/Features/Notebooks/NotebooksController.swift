//
//  NotebooksController.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

class NotebooksController {
    
    let notebooksBusiness = BusinessFactory.createNotebooksFactoryNew()
    let presenter = NotebooksPresenter()
    
    
//    func createNotebooksPresenter() -> NotebooksPresenter {
//        
//        return NotebooksPresenter(controller: self)
//    }
    
    func getNotebooks() async {
        do {
            let notebooksH = try await notebooksBusiness.fetchNotebooksHierarchy()
            presenter.showNotebooksList(notebooksH: notebooksH)
        } catch let error {
            print(error)
        }
    }
    
    func validateFileName(string: String) {
        let response = try? notebooksBusiness.getRootNotebookOnly()
        presenter.handleValidationResponse(data: "response data")
    }
}
