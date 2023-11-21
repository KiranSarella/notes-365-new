//
//  NotebookContentRequester.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebookContentRequester {
    func fetchNotebookContent(for id: UUID) throws -> NotebookContentB
    func deleteNotebookContent(for id: UUID) throws
    func insert(notebookContent: NotebookContentB) throws
    func update(notebookContent: NotebookContentB) throws
}

extension NotebookContentBusinessNew: NotebookContentRequester {
    
}
