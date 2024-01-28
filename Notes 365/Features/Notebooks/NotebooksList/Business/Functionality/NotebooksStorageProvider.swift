//
//  File.swift
//  
//
//  Created by kiran ipc on 15/11/23.
//

import Foundation

protocol NotebooksStorageProvider {
    func fetchNotebooksCount() throws -> Int
    func getRootNotebook() throws -> NotebookB?
    func searchActiveNotebooks(for searchText: String) throws -> [NotebookB]
    func fetchAllNotebooks() async throws -> [NotebookB]
//    func fetchDeletedNotebooks() async throws -> [NotebookB]
    func insert(notebook: NotebookB) throws
    func update(notebook: NotebookB) throws
    func getNotebook(for id: UUID) throws -> NotebookB
    func getActiveTopLevelNotebooks() throws -> [NotebookB]
//    func getChildren(forParent id: UUID) throws -> [NotebookB]
    func getActiveChildren(forParent id: UUID) throws -> [NotebookB]
    // info
    func getAllFilesInfo() throws -> [NotebookB]
    func getAllFolders() throws -> [NotebookB]
    func fetchOnlyNotesCount() throws -> Int

    func deleteAllRecords() throws
    func getDeletedNotebooks() throws -> [NotebookB]
    func fetchExpiredDeletedNotebooks(expiryDate: Date) throws -> [NotebookB]
    func permanentDelete(notebookId: UUID) throws
}
