//
//  NotebooksGateway.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebooksRequester {
    func fetchAllNotebooks() async throws -> [NotebookB]
    func searchItems(for searchText: String) throws -> [NotebookB]
    func fetchItems(at parent: UUID?) throws -> [NotebookB]
//    func fetchRootItems() throws -> [NotebookB]
    func getRootNotebookOnly() throws -> NotebookB?
    func getNotebook(id: UUID) throws -> NotebookB
//    func createRootNotebook() throws -> NotebookB
    func createFolder(inside parent: NotebookB?, siblings: [NotebookB]) throws -> NotebookB
    func createFile(inside parent: NotebookB?, siblings: [NotebookB]) throws -> NotebookB
    func deleteNotebook(notebook: NotebookB) throws
    func rename(notebook: NotebookB, newValue: String, siblings: [NotebookB]) throws
    
    func getAllFilesInfo() -> [NotebookB]
    func fetchAllFolders() throws -> [NotebookB]
    func move(notebook: NotebookB, to destinationId: UUID?) throws
    
    func fetchOnlyNotesCount() throws -> Int
    
    func fetchDeletedNotebooks() throws -> [NotebookB]
    func restore(notebook: NotebookB, to destinationId: UUID?) throws
    func permanentDeleteExpiredItems() async
}

extension NotebooksBusiness: NotebooksRequester {
    
}

extension Notification.Name {
    public static let notebookRenamed = Notification.Name("com.notes365.notebookRenamed")
    public static let notebookInserted = Notification.Name("com.notes365.notebookInserted")
    public static let notebooksMoved = Notification.Name("com.notes365.notebooksMoved")
    public static let notebookDeleted = Notification.Name("com.notes365.notebookDeleted")
}
