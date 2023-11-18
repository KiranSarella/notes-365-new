//
//  NotebooksPresenter.swift
//  Notes 365
//
//  Created by kiran ipc on 13/11/23.
//

//import Foundation
//import SwiftUI
//
//class NotebooksPresenter {
//    
//    var notebooksVM = NotebooksListState()
//    
//    func showNotebooksList(notebooks: [NotebookB]) {
//        
//        // prepare dict
//        var dict = [UUID: NotebookB]()
//        for result in notebooks {
//            dict[result.id] = result
//        }
//        // topLevel
//        var topLevels: [NotebookB] = notebooks.filter { $0.parentId == nil }
////                    .sorted { $0.orderID < $1.orderID }
////            topLevels.removeAll(where: { $0.isDeleted })
//        
//        // notebooks
//        var notebooksList = [Notebook]()
//        for topNote in topLevels {
//            notebooksList.append(topNote.notebook())
//        }
//        // populate childnotes
//        for notebook in notebooksList {
//            notebook.populateChildren(from: dict)
//        }
//        
//        notebooksVM.notebooks = notebooksList
//        notebooksVM.isLoading = false
//    }
//    
//    private func formNotebooksHierarchy(from notebooksData: [NotebookB]) -> Notebook? {
//        // prepare dict
//        var dict = [UUID: NotebookB]()
//        for result in notebooksData {
//            dict[result.id] = result
//        }
//        guard let rootNotebookData = notebooksData.first(where: { $0.parentId == nil }) else { return nil }
//        let rootNotebook = rootNotebookData.notebook()
//        rootNotebook.populateChildren(from: dict)
//        return rootNotebook
//    }
//    
//}


//extension NotebookB {
//    
//    func notebook() -> Notebook {
//        
//        let notebook = Notebook(id: id, name: name)
//        notebook.createdDate = createdDate
//        notebook.modifiedDate = modifiedDate
//        notebook.deletedDate = deletedDate
//        
//        notebook.parentId = parentId
//        notebook.childrenIds = childrenIds
//        
//        return notebook
//    }
//    
//}
//

