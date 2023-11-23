//
//  NotebooksGateway.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebooksRequester {
    func fetchAllNotebooks() async throws -> [NotebookB]
    func fetchItems(at parent: UUID) throws -> [NotebookB]
    func getRootNotebookOnly() throws -> NotebookB?
    func getNotebook(id: UUID) throws -> NotebookB
    func createRootNotebook() throws -> NotebookB
    func createFolder(inside parent: NotebookB, siblings: [NotebookB]) throws -> NotebookB
    func createFile(inside parent: NotebookB, siblings: [NotebookB]) throws -> NotebookB
    func deleteNotebook(notebook: NotebookB, parent: NotebookB) throws
    func rename(notebook: NotebookB, newValue: String, siblings: [NotebookB]) throws
}

extension NotebooksBusiness: NotebooksRequester { }
