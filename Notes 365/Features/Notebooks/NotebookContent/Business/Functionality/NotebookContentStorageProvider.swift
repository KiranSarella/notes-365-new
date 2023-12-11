//
//  NotebookContentStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import Foundation

protocol NotebookContentStorageProvider {
    
    func fetchNotebookContent(for id: UUID) throws -> NotebookContentB?
    func deleteNotebookContent(for id: UUID) throws
    func insert(notebookContent: NotebookContentB) throws
    func update(notebookContent: NotebookContentB) throws
    func deleteAllRecords() throws
}
