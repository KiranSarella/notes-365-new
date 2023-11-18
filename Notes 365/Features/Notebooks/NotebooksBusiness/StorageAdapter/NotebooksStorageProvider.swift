//
//  File.swift
//  
//
//  Created by kiran ipc on 15/11/23.
//

import Foundation

protocol NotebooksStorageProvider {
    
    func getRootNotebook() throws -> NotebookB?
    func fetchAllNotebooks() async throws -> [NotebookB]
//    func fetchDeletedNotebooks() async throws -> [NotebookB]
    func insert(notebook: NotebookB) throws
    func update(notebook: NotebookB) throws
    func getNotebook(for id: UUID) throws -> NotebookB
    func getTopLevelNotebooks() throws -> [NotebookB]
    func getChildren(forParent id: UUID) throws -> [NotebookB]
}
