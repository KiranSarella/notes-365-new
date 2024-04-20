//
//  NotebookContentRequester.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import Foundation

protocol NotebookContentRequester {
    func retrieveOrInstantiateNotebookContent(for id: UUID) throws -> NotebookContentB
    func deleteNotebookContent(for id: UUID) throws
    func insert(notebookContent: NotebookContentB) throws
    func update(notebookContent: NotebookContentB) throws
}

extension NotebookContentBusinessNew: NotebookContentRequester {
    
}

extension Notification.Name {
    public static let notebookContentWillUpdate = Notification.Name("com.notes365.notebookContentWillUpdate")
    public static let notebookContentLoaded = Notification.Name("com.notes365.notebookContentLoaded")
}

