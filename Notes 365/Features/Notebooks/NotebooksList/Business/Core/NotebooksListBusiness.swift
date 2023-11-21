//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import UIKit
import SwiftData

extension  Notification.Name {
    public static let notebookChangeNotification = Notification.Name("NotebookChangeNotification")
}

public enum NotebookBusinessError: Error {
    case alreadyExists
    case invalidCharacters
    case invalidSelection
}

class NotebooksListBusiness {
    
    var basePathURL: URL
    private var listSyncDate: Date = Date()
    
    private let deleteDays = 30
    
    var modelContext: ModelContext?
    
    let notebooksPath = Constants.notebooksFolderName
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
    }
    
    
//    func fetchDeletedNotebooks() async -> [Notebook]? {
//        
//        await withCheckedContinuation { continuation in
//            
//            guard
//                let modelContext = modelContext
//            else {
//                continuation.resume(returning: nil)
//                return
//            }
//            
//            let allListPredicate = #Predicate<NotebookData> { _ in
//                true
//            }
//            let descriptor = FetchDescriptor(predicate: allListPredicate)
//    //        let descriptor = FetchDescriptor(predicate: allListPredicate, sortBy: [SortDescriptor(\NotebookData.orderID)])
//            
//            do {
//                let results: [NotebookData] = try modelContext.fetch(descriptor)
//                // prepare dict
//                var dict = [UUID: NotebookData]()
//                for result in results {
//                    dict[result.id] = result
//                }
//                
//                // deleted topLevel
//                var topLevels: [NotebookData] = results.filter { $0.isDeleted == true }
//                    
//                topLevels.sort { n1, n2 in
//                    n1.deletedDate! > n2.deletedDate!
//                }
//                
//                // notebooks
//                var notebooksList = [Notebook]()
//                for topNote in topLevels {
//                    notebooksList.append(Notebook(topNote))
//                }
//                // populate childnotes
//                for notebook in notebooksList {
//                    notebook.populateChildren(from: dict)
//                }
//                
//                continuation.resume(returning: notebooksList)
//            } catch let err {
//                print(err)
//                continuation.resume(returning: nil)
//            }
//            
//        }
//    }
    

}


// MARK: - Deleted Notebooks
extension NotebooksListBusiness {
    
    func deleteDateExceededNotebooks(deletedNotebooks: inout [Notebook]) {
        // delete files that are 30 days old
        
        guard let modelContext = modelContext else { return }
        
        var oldNotebooks = [Notebook]()
        var remainingNotebooks = [Notebook]()
        
        for notebook in deletedNotebooks {
            guard let deletedDate = notebook.deletedDate else { return }
            if numberOfDaysBetween(deletedDate, and: Date()) > deleteDays {
                oldNotebooks.append(notebook)
            } else {
                remainingNotebooks.append(notebook)
            }
        }
        
        // delete content items
         for notebook in oldNotebooks {
            // delete notebook info from list
            modelContext.delete(notebook.notebookData)
            // delete notebook content
//            NotebookContentBusiness.deleteNotebookContent(for: notebook.id, in: modelContext)
            
            // nested items delete
             if notebook.containChildNotebooks {
                 deleteNestedPerminantly(deletedNotebooks: notebook.children)
            }
        }
        
        deletedNotebooks = remainingNotebooks
    }
    
    func deleteNestedPerminantly(deletedNotebooks: [Notebook]) {
        guard let modelContext = modelContext else { return }
        
        for notebook in deletedNotebooks {
            // delete notebook info from list
            modelContext.delete(notebook.notebookData)
            // delete notebook content
//            NotebookContentBusiness.deleteNotebookContent(for: notebook.id, in: modelContext)
            
            // nested items delete
            if notebook.containChildNotebooks {
                deleteNestedPerminantly(deletedNotebooks: notebook.children)
            }
        }
    }
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day!
    }
    
}
