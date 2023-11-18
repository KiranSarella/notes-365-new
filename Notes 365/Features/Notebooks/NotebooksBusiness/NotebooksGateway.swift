//
//  NotebooksGateway.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebooksGateway {
    
    func fetchNotebooksHierarchy() async throws -> Notebook?
    
    func fetchDeletedNotebooks() async -> [Notebook]
    
    func getRootNotebookOnly() throws -> Notebook?
    
    func createRootNotebook() throws -> Notebook
    
    func createNotebook() throws -> Notebook
    
    func createNotebook(inside parentId: UUID, at position: Int?) throws -> Notebook
}

extension NotebooksBusiness: NotebooksGateway {
    
}
