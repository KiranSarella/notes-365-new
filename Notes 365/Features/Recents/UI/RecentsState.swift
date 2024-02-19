//
//  RecentsState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

@Observable
class RecentsState {
    var folders = [RecentNotebook]()
    var files = [RecentNotebook]()
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    let business: RecentsInteractor = BusinessFactory.recentsInteractor()
    
    func loadRecents() {
        do {
            let items = try business.loadRecents()
            let notebooks = items.map { $0.notebook }
            let folderItems = notebooks.filter { $0.isFolder }.sorted(by: { n1, n2 in
                n1.modifiedDate > n2.modifiedDate
            })
            folders = folderItems.map { RecentNotebook(id: $0.id, notebook: $0) }
            let fileItems = notebooks.filter { !$0.isFolder }.sorted(by: { n1, n2 in
                n1.modifiedDate > n2.modifiedDate
            })
            files = fileItems.map { RecentNotebook(id: $0.id, notebook: $0) }
//            print(folders.map { "\($0.name) - \($0.id.uuidString)"})
//            print(files.map { "\($0.name) - \($0.id.uuidString)"})
        } catch let error {
            print(error)
        }
    }
}

extension RecentItem {
    var notebook: Notebook {
        let n = Notebook(id: id, name: name)
        n.isFolder = isFolder
        n.modifiedDate = updatedDate
        return n
    }
}
