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
    var childrenIds: [UUID]?
    var children: [Notebook] = [Notebook]()
    var createdDate: Date = DateTime.now()
    var modifiedDate: Date = DateTime.now()
    var deletedDate: Date? = nil
    var notebookData: NotebookData
    var isExpanded: Bool = false
    var isDeleted: Bool = false
    var canShow: Bool = true
    
    func sortChildren() {
        children.sort { n1, n2 in
            n1.priority < n2.priority// && n1.createdDate < n2.createdDate
        }
    }
    
    var priority: Int {
        isFolder ? 0 : 1
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        notebookData = NotebookData(id: id, name: name)
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

// MARK: - children
extension Notebook {
    func insertChild(notebook newValue: Notebook) {
        self.children.append(newValue)
        sortChildren()
    }
    
    func deleteChildren(where id: UUID) {
        children.removeAll(where: { $0.id == id })
    }
    
    func populateChildren(from dict: [UUID: NotebookB], expandedIds: Set<String>) {
        guard let cArr = childrenIds, !cArr.isEmpty else { return }
        children = [Notebook]()
        for cid in cArr {
            if let noteD = dict[cid] {
                let note = noteD.notebook()
                note.parentId = self.id
                note.isExpanded = expandedIds.contains(note.id.uuidString)
                children.append(note)
            }
        }
        for cNote in children {
            cNote.populateChildren(from: dict, expandedIds: expandedIds)
            cNote.sortChildren()
        }
    }
    
    var containChildNotebooks: Bool {
        childrenCount > 0
    }
    
    var childrenCount: Int {
        children.count
    }
 
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
