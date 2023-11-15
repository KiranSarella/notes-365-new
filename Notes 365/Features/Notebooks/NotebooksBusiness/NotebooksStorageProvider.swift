//
//  File.swift
//  
//
//  Created by kiran ipc on 15/11/23.
//

import Foundation

protocol NotebooksStorageProvider {
    
    func fetchNotebooks() async throws -> [Notebook]
    func fetchDeletedNotebooks() async throws -> [Notebook]
    func insert(notebook: Notebook) throws
    func update(notebook: Notebook) throws
    func getNotebook(for id: UUID) throws -> Notebook
    func getTopLevelNotebooks() throws -> [Notebook]
    func getChildren(forParent id: UUID) throws -> [Notebook]
}
