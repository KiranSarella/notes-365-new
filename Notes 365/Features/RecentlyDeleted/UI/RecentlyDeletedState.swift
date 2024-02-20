//
//  RecentlyDeletedState.swift
//  Notes 365
//
//  Created by kiran ipc on 20/01/24.
//

import Foundation

@Observable
class RecentlyDeletedState {
    var folders = [DeletedNotebook]()
    var files = [DeletedNotebook]()
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    let business: NotebooksRequester = BusinessFactory.createNotebooksFactory()
    
    func loadRecentlyDeleted() {
        logger.debug("\(#function)")
        do {
            let items = try business.fetchDeletedNotebooks()
            let notebooks = items.map { $0.deletedNotebook() }
            folders = notebooks.filter { $0.notebook.isFolder }.sorted(by: { n1, n2 in
                n1.notebook.modifiedDate > n2.notebook.modifiedDate
            })
            files = notebooks.filter { !$0.notebook.isFolder }.sorted(by: { n1, n2 in
                n1.notebook.modifiedDate > n2.notebook.modifiedDate
            })
            print(folders.map { "\($0.notebook.name) - \($0.id.uuidString)"})
            print(files.map { "\($0.notebook.name) - \($0.id.uuidString)"})
        } catch let error {
            print(error)
        }
    }
    
    func restore(_ source: Notebook, to destinationId: UUID?) {
        logger.info("\(#function) from: \(source.name) to: \(destinationId?.uuidString ?? "")")
        do {
            try business.restore(notebook: source.notebookB(), to: destinationId)
        } catch {
            logger.info("\(error)")
        }
        
        if source.isFolder {
            folders.removeAll { nt in
                nt.id == source.id
            }
        } else {
            files.removeAll { nt in
                nt.id == source.id
            }
        }
        
    }
}

extension NotebookB {
    func deletedNotebook() -> DeletedNotebook {
        DeletedNotebook(id: id, notebook: notebook())
    }
}
