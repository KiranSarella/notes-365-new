//
//  RecentlyDeletedState.swift
//  Notes 365
//
//  Created by kiran ipc on 20/01/24.
//

import Foundation

@Observable
class RecentlyDeletedState {
    var folders = [Notebook]()
    var files = [Notebook]()
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    let business: NotebooksRequester = BusinessFactory.createNotebooksFactory()
    
    func loadRecentlyDeleted() {
        do {
            let items = try business.fetchDeletedNotebooks()
            let notebooks = items.map { $0.notebook() }
            folders = notebooks.filter { $0.isFolder }.sorted(by: { n1, n2 in
                n1.modifiedDate > n2.modifiedDate
            })
            files = notebooks.filter { !$0.isFolder }.sorted(by: { n1, n2 in
                n1.modifiedDate > n2.modifiedDate
            })
            print(folders.map { "\($0.name) - \($0.id.uuidString)"})
            print(files.map { "\($0.name) - \($0.id.uuidString)"})
        } catch let error {
            print(error)
        }
    }
}
