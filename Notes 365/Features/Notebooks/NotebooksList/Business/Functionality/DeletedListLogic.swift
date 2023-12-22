//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

//// MARK: - Deleted Notebooks
//extension NotebooksListBusiness {
//    
//    func deleteDateExceededNotebooks(deletedNotebooks: inout [Notebook]) {
//        // delete files that are 30 days old
//        
//        guard let modelContext = modelContext else { return }
//        
//        var oldNotebooks = [Notebook]()
//        var remainingNotebooks = [Notebook]()
//        
//        for notebook in deletedNotebooks {
//            guard let deletedDate = notebook.deletedDate else { return }
//            if numberOfDaysBetween(deletedDate, and: DateTime.now()) > deleteDays {
//                oldNotebooks.append(notebook)
//            } else {
//                remainingNotebooks.append(notebook)
//            }
//        }
//        
//        // delete content items
//         for notebook in oldNotebooks {
//            // delete notebook info from list
//            modelContext.delete(notebook.notebookData)
//            // delete notebook content
////            NotebookContentBusiness.deleteNotebookContent(for: notebook.id, in: modelContext)
//            
//            // nested items delete
//             if notebook.containChildNotebooks {
//                 deleteNestedPerminantly(deletedNotebooks: notebook.children ?? [])
//            }
//        }
//        
//        deletedNotebooks = remainingNotebooks
//    }
//    
//    func deleteNestedPerminantly(deletedNotebooks: [Notebook]) {
//        guard let modelContext = modelContext else { return }
//        
//        for notebook in deletedNotebooks {
//            // delete notebook info from list
//            modelContext.delete(notebook.notebookData)
//            // delete notebook content
////            NotebookContentBusiness.deleteNotebookContent(for: notebook.id, in: modelContext)
//            
//            // nested items delete
//            if notebook.containChildNotebooks {
//                deleteNestedPerminantly(deletedNotebooks: notebook.children ?? [])
//            }
//        }
//    }
//    
//    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
//        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)
//        
//        return numberOfDays.day!
//    }
//    
//}
