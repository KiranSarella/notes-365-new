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

    var childrenIds: [UUID]?
    // private(set)
    var children: [Notebook] = [Notebook]()
    
    var createdDate: Date = Date()
    var modifiedDate: Date = Date()
    var deletedDate: Date? = nil
    
    
//    var orderID: Int = 0
    
    var parentId: UUID?
    private(set) var parent: Notebook?
    
    var notebookData: NotebookData
    
    var isExpanded: Bool = false
    var isDeleted: Bool = false
    var canShow: Bool = true
    
    func sortChildren() {
//        if children != nil {
//            children!.sort(by: { n1, n2 in
//                n1.orderID < n2.orderID
//            })
//            
//            // apply to nested
//            for i in 0..<children!.count {
//                children![i].sortChildren()
//            }
//        }
    }
    
    func onlySelfSortChildren() {
//        if children != nil {
//            
//            print("## before")
//            for c in children! {
//                print(c.orderID)
//            }
////
////            children!.sort(by: { n1, n2 in
////                n1.orderID < n2.orderID
////            })
////
////            print("## after")
////            for c in children! {
////                print(c.orderID)
////            }
//            
//            print("# manual")
//            if let sortedArr = children?.sorted(by: { $0.orderID < $1.orderID }) {
//                
//                children = sortedArr
//                
//                for c in sortedArr {
//                    print(c.orderID)
//                }
//                print("---")
//                for c in children! {
//                    print(c.orderID)
//                }
//            }
//            
//        }
    }
    
    init(_ notebookData: NotebookData) {
        
        self.notebookData = notebookData
        
        self.id = notebookData.id
        self.name = notebookData.name
//        self.orderID = notebookData.orderID
        self.createdDate = notebookData.createdDate
        self.modifiedDate = notebookData.modifiedDate
        self.deletedDate = notebookData.deletedDate
        
        // lazy load actual parent and chldrens ?
        self.parentId = notebookData.parent
        self.childrenIds = notebookData.children
        
        // self.parent = // asign parent external
        //        self.children = // get children objects
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


// MARK: - children
extension Notebook {
    
    func setChildren(notebooks newList: [Notebook]) {
        self.children = newList
        updateChildrenIds()
    }
    
    func appendChildren(notebook newValue: Notebook) {
        if self.containChildNotebooks {
            self.children.append(newValue)
            updateChildrenIds()
        } else {
            setChildren(notebooks: [newValue])
        }
    }
    
    func insertChild(notebook newValue: Notebook, at position: Int) throws {
        if position <= childrenCount {
            if containChildNotebooks {
                self.children.insert(newValue, at: position)
                updateChildrenIds()
            } else {
                self.setChildren(notebooks: [newValue])
            }
        } else {
            throw NotebooksBusinessError.invalidPosition
        }
    }
    
    func deleteChildren(where id: UUID) {
        children.removeAll(where: { $0.id == id })
        updateChildrenIds()
    }
    
    private func updateChildrenIds() {
        self.childrenIds = children.map { $0.id }
    }
    
    func populateChildren(from dict: [UUID: NotebookB]) {
        
        guard let cArr = childrenIds, !cArr.isEmpty else { return }
        
        children = [Notebook]()
        for cid in cArr {
            if let noteD = dict[cid] {
                // if deleted, discard that node and heirarchy
                if noteD.isDeleted { continue } // continue vs return - remember
                let note = noteD.notebook()
                note.parent = self
                children.append(note)
            }
        }
        // populate inner list
        // populate childnotes
        for cNote in children {
            cNote.populateChildren(from: dict)
        }
    }
    
    var containChildNotebooks: Bool {
        childrenCount > 0
    }
    
    var childrenCount: Int {
        return children.count
    }
    
    func linkSelfToChildren() {
        _ = children.map { $0.parent = self }
    }
 
}

extension Notebook {
    
    func syncNotebookData() {
        
        notebookData.id = id
        notebookData.name = name
//        notebookData.orderID = orderID
        notebookData.parent = parent?.id
        notebookData.children = children.map { $0.id }
        
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
