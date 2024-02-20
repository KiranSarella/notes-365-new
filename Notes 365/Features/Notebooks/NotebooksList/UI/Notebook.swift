//
//  Models.swift
//  Notes 365
//
//  Created by kiran ipc on 14/11/23.
//

import Foundation

@Observable
class Notebook: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var parentId: UUID?
    var isFolder: Bool = true
    
    var createdDate: Date = DateTime.now()
    var modifiedDate: Date = DateTime.now()
    var deletedDate: Date? = nil

    var isNewlyCreated = false
    
    var priority: Int {
        isFolder ? 0 : 1
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: - parent
    func updateParent(_ newValue: Notebook?) {
        self.parentId = newValue?.id
    }
}

extension Notebook: Equatable, Hashable {
    static func == (lhs: Notebook, rhs: Notebook) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Notebook: CustomStringConvertible {
    var description: String { name }
}

extension NotebookB {
    func notebook() -> Notebook {
        let notebook = Notebook(id: id, name: name)
        notebook.parentId = parentId
        notebook.isFolder = isFolder
        notebook.createdDate = createdDate
        notebook.modifiedDate = modifiedDate
        notebook.deletedDate = deletedDate
        return notebook
    }
    
    
}

extension Notebook {
    func notebookB() -> NotebookB {
        let notebookB = NotebookB(id: id, name: name)
        notebookB.parentId = parentId
        notebookB.isFolder = isFolder
        notebookB.createdDate = createdDate
        notebookB.modifiedDate = modifiedDate
        notebookB.deletedDate = deletedDate
        return notebookB
    }
}
