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
            
            let folderItems = try business.loadRecentFolders()
            folders = folderItems.map { RecentNotebook(id: $0.id, notebook: $0.notebook) }
            
            let fileItems = try business.loadRecentFiles()
            files = fileItems.map { RecentNotebook(id: $0.id, notebook: $0.notebook) }
        } catch let error {
            logger.error("\(error)")
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
