//
//  CurrentLevelState.swift
//  Notes 365
//
//  Created by kiran ipc on 23/11/23.
//

import Foundation
import SwiftUI
import os

@Observable
class CurrentLevelState {
    
    let notebooksBusiness: NotebooksRequester = BusinessFactory.createNotebooksFactory()
    var parent: Notebook?
    var folders = [Notebook]()
    var files = [Notebook]()
    
    var isCreatingNotebook = false
    var cloudSyncFinishedObserver: NSObjectProtocol?
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var searchText: String = ""
    
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    
    var siblings: [Notebook] {
        folders + files
    }
    
    init() {
        // listen for move updates, if destination is yours, add them to your list
        observeNotebookMoved()
        observeCloudFinished()
    }
    
    deinit {
        removeNotebookMovedObserver()
    }
    
    func refreshList() {
        loadItems(for: self.parent)
    }

    func searchItems(for searchText: String) {
        do {
            let items = try notebooksBusiness.searchItems(for: searchText)
            let notebooks = items.map { $0.notebook() }
            folders = notebooks.filter { $0.isFolder }.sorted(by: { n1, n2 in
                n1.name < n2.name
            })
            files = notebooks.filter { !$0.isFolder }.sorted(by: { n1, n2 in
                n1.name < n2.name
            })
            print(folders.map { "\($0.name) - \($0.id.uuidString)"})
            print(files.map { "\($0.name) - \($0.id.uuidString)"})
        } catch let error {
            print(error)
        }
    }
    
    func loadItems(for parent: Notebook?) {
        self.parent = parent
        do {
            let items = try notebooksBusiness.fetchItems(at: parent?.id)
            let notebooks = items.map { $0.notebook() }
            folders = notebooks.filter { $0.isFolder }.sorted(by: { n1, n2 in
                n1.name < n2.name
            })
            files = notebooks.filter { !$0.isFolder }.sorted(by: { n1, n2 in
                n1.name < n2.name
            })
            print(folders.map { "\($0.name) - \($0.id.uuidString)"})
            print(files.map { "\($0.name) - \($0.id.uuidString)"})
        } catch let error {
            print(error)
        }
    }
    
    func createFolder() {
        let siblings = self.siblings.map { $0.notebookB() }
        do {
            let newNotebookB = try notebooksBusiness.createFolder(inside: parent?.notebookB(), siblings: siblings)
            let newNotebook = newNotebookB.notebook()
            newNotebook.updateParent(parent)
            self.folders.append(newNotebook)
            self.folders.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        } catch let error {
            print(error)
        }
    }
    
    func createFile() {
        let siblings = self.siblings.map { $0.notebookB() }
        do {
            let newNotebookB = try notebooksBusiness.createFile(inside: parent?.notebookB(), siblings: siblings)
            let newNotebook = newNotebookB.notebook()
            newNotebook.updateParent(parent)
            self.files.append(newNotebook)
            self.files.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        } catch let error {
            print(error)
        }
    }
    
    func rename(for notebook: Notebook, newValue: String) throws {
        let siblings = self.siblings.map { $0.notebookB() }
        try notebooksBusiness.rename(notebook: notebook.notebookB(),
                                     newValue: newValue,
                                     siblings: siblings)
        notebook.name = newValue
        if notebook.isFolder {
            self.folders.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        } else {
            self.files.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        }
    }
    
    func deleteFile(notebook: Notebook) {
        do {
            try notebooksBusiness.deleteNotebook(notebook: notebook.notebookB())
        } catch let error {
            print(error)
            return
        }
        // delete from UI
        files.removeAll(where: { $0.id == notebook.id })
    }
    
    func deleteFolder(notebook: Notebook) {
        do {
            try notebooksBusiness.deleteNotebook(notebook: notebook.notebookB())
        } catch let error {
            print(error)
            return
        }
        // delete from UI
        folders.removeAll(where: { $0.id == notebook.id })
    }
    
    func move(_ source: Notebook, to destinationId: UUID?) {
        logger.info("\(#function) from: \(source.name) to: \(destinationId?.uuidString ?? "")")
        do {
            try notebooksBusiness.move(notebook: source.notebookB(), to: destinationId)
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

extension CurrentLevelState {
    func observeNotebookMoved() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookMoved(_:)), name: Notification.Name.notebooksMoved, object: nil)
    }
    
    func removeNotebookMovedObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebooksMoved, object: nil)
    }
    
    
    @objc func handleNotebookMoved(_ notification: Notification) {
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let name = notification.userInfo?["name"] as? String,
            let isFolder = notification.userInfo?["isFolder"] as? Bool
        else { return }
                
        let parentId = notification.userInfo?["parent_id"] as? UUID
        
        var isMovedToThisLevel: Bool {
            parentId == parent?.id
        }
        
        if isMovedToThisLevel == false {
            return
        }
        
        let item = Notebook(id: notebookId, name: name)
        item.isFolder = isFolder
        item.parentId = parentId
        
        if isFolder {
            folders.append(item)
            folders.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        } else {
            files.append(item)
            files.sort(by: { n1, n2 in
                n1.name < n2.name
            })
        }
        
    }
}


extension CurrentLevelState {
    
    func observeCloudFinished() {
        cloudSyncFinishedObserver = NotificationCenter.default.addObserver(forName: .icloudSyncFinished, object: nil, queue: .main) { [weak self] notification in
            
            guard let self = self else { return }
            
            if self.parent == nil && isSearching == false {
                self.refreshList()
            }
        }
    }
    
}
