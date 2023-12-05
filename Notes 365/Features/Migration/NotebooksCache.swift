//
//  NotebooksCache.swift
//  Notes 365
//
//  Created by kiran ipc on 05/12/23.
//

import Foundation

class NotebooksCache {
    static let shared = NotebooksCache()
    var flatNotebooks = [String: NotebookOld]()
    
    func clear() {
        flatNotebooks.removeAll()
    }
    
    func store(notebook: NotebookOld) {
        flatNotebooks[notebook.id.uuidString] = notebook
    }
    
    func remove(notebook: NotebookOld) {
        flatNotebooks.removeValue(forKey: notebook.id.uuidString)
    }
}
