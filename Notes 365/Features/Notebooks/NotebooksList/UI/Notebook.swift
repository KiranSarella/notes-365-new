//
//  Models.swift
//  Notes 365
//
//  Created by kiran ipc on 14/11/23.
//

import Foundation
import SwiftData


/*
 getParent() -> Notebook
 // have to maintain [childID: parentID] dictionary
 // - when new child added, insert here
 // - no persistance is required, in-mem instant only
 // - when grouping changed
 
 getChildren() -> [Notebook]
 
 */

@Observable
class Notebook: Identifiable {
    
    var id: UUID = UUID()
    var name: String = ""

    var parentId: UUID?
    private(set) var parent: Notebook?
    
    var isFolder: Bool = true
    var childrenIds: [UUID]?
    // private(set)
    var children: [Notebook] = [Notebook]()
    
    var createdDate: Date = Date()
    var modifiedDate: Date = Date()
    var deletedDate: Date? = nil
    
    var notebookData: NotebookData
    
    var isExpanded: Bool = false
    var isDeleted: Bool = false
    var canShow: Bool = true
    
    func sortChildren() {
//        children
//            .sort { n1, n2 in  n1.isFolder }
////            .sort { n1, n2 in   n1.createdDate < n2.createdDate }
//        children.sort { n1, n2 in
//            n1.createdDate < n2.createdDate
//        }
        
        children.sort { n1, n2 in
            n1.priority < n2.priority// && n1.createdDate < n2.createdDate
        }
//        children.sort { n1, n2 in
//            n1.isFolder && n1.createdDate < n2.createdDate
//        }
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
        self.parent = newValue
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
                note.parent = self
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
        return children.count
    }
 
}

extension Notebook {
    
    func syncNotebookData() {
        
        notebookData.id = id
        notebookData.name = name
//        notebookData.orderID = orderID
        notebookData.parent = parent?.id
        
        notebookData.createdDate = createdDate
        notebookData.modifiedDate = modifiedDate
        notebookData.deletedDate = deletedDate
    }
    
    func saveNotebookData(_ modelContext: ModelContext) {
        syncNotebookData()
        do {
            modelContext.insert(notebookData)
            try modelContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func updateNotebookData(_ modelContext: ModelContext) {
        syncNotebookData()
        do {
            try modelContext.save()
        } catch let error {
            print(error)
        }
    }
}

extension Notebook {
    
    var uuidPath: [UUID] {
        
        var uuids = [UUID]()
        // add self
        uuids.append(self.id)
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            uuids.append(parentRef!.id)
            parentRef = parentRef?.parent
        }
        
        return uuids.reversed()
    }
    
    var filePath: String {
        return self.id.uuidString + ".md"
    }
    
    
    var oldFilePath: String {
        
        // add self
        var path: String = self.name + ".md"
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            path = parentRef!.name + "/" + path
            parentRef = parentRef?.parent
        }
        // return
        return path
    }
    
    var folderPath: String {
        // add self
        var path: String = self.name
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            path = parentRef!.name + "/" + path
            parentRef = parentRef?.parent
        }
        // return
        return path
    }
    
    var folderPaths: [String] {
        // add self
        var paths = [self.name]
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            paths.append(parentRef!.name)
            // next
            parentRef = parentRef?.parent
        }
        // return
        return paths.reversed()
    }
}
