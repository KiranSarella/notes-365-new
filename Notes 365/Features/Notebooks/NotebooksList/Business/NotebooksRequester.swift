//
//  NotebooksGateway.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebooksRequester {
    
    func fetchAllNotebooks() async throws -> [NotebookB]
    
//    func fetchDeletedNotebooks() async -> [NotebookB]
    
    func getRootNotebookOnly() throws -> NotebookB?
    
    func getNotebook(id: UUID) throws -> NotebookB
    
    func createRootNotebook() throws -> NotebookB
    
    func createNotebook() throws -> NotebookB
    
//    func createNotebook(inside parentId: UUID, at position: Int?) throws -> Notebook
    
    func createNotebook(inside parent: NotebookB, below notebookId: UUID?, children: [NotebookB]?) throws -> NotebookB
    
    func deleteNotebook(notebook: NotebookB, parent: NotebookB) throws
    func rename(notebook: NotebookB, newValue: String, siblings: [NotebookB]) throws
}

extension NotebooksBusiness: NotebooksRequester {
    
}
