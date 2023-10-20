//
//  NotebookBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftData

/*
 
 purpose: notebook + timeline handling
 
 */


class NotebookContentBusiness {
    
    static let notebooksPath = Constants.notebooksFolderName
    static let baseVersionPath = Constants.todayBaseVersionFolderName
    
//    func saveContentChanges(content: String, notebook: Notebook) {
////        print(#function)
//        // write updated content to file
////        notebook.saveContent(content: content)
//        // send notification
//        // TODO: send notification after some delay - based on result.
//        let info = [
//            "id": notebook.id,
//            "notebookName": notebook.name,
//            "notebookPath": notebook.folderPaths
//        ] as [String : Any]
//        NotificationCenter.default.post(name: Notification.Name.notebookContentUpdated, object: nil, userInfo: info)
//    }
    
    static func fetchNotebookContent(for id: UUID, in modelContext: ModelContext) -> NotebookContent? {
        
        let contentPredicate = #Predicate<NotebookContent> {
            $0.notebookID == id
        }
                
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1

        do {
            let trips = try modelContext.fetch(descriptor)
            return trips.first
        } catch let err {
            print(err)
            return nil
        }
    }
    
    static func deleteNotebookContent(for id: UUID, in modelContext: ModelContext) {
        
        let contentPredicate = #Predicate<NotebookContent> {
            $0.notebookID == id
        }
                
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1

        do {
            try modelContext.delete(model: NotebookContent.self, where: contentPredicate)
        } catch let err {
            print(err)
        }
    }
    
    
}
