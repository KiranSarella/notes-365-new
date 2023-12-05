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
    
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    
    var siblings: [Notebook] {
        folders + files
    }
    
    init() {
        
    }
    
    func loadItems(for parent: Notebook?) {
        self.parent = parent
        do {
            let items = try notebooksBusiness.fetchItems(at: parent?.id)
            let notebooks = items.map { $0.notebook() }
            folders = notebooks.filter { $0.isFolder }
            files = notebooks.filter { !$0.isFolder }
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
}
