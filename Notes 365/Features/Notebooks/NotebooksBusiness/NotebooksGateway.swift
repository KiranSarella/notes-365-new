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
    
    func createRootNotebook() throws -> NotebookB
    
    func createNotebook() throws -> NotebookB
    
//    func createNotebook(inside parentId: UUID, at position: Int?) throws -> Notebook
    
    func createNotebook(inside parent: NotebookB, at position: Int?, children: [NotebookB]?) throws -> NotebookB
}

extension NotebooksBusiness: NotebooksRequester {
    
}
