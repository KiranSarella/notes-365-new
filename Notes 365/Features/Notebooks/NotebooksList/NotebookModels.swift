//
//  NotebookModels.swift
//  Notes 365
//
//  Created by kiran ipc on 18/11/23.
//

import Foundation
import SwiftUI

class NotebookVM: Identifiable {
    
    var id: UUID = UUID()
    var name: String = ""

    var childrenIds: [UUID]?
    // private(set)
    var children: [NotebookVM]?
    
    var createdDate: Date = Date()
    var deletedDate: Date? = nil
    var modifiedDate: Date = Date()
    
    var parentId: UUID?
    private(set) var parent: NotebookVM?
    var isExpanded: Bool = false
    var isDeleted: Bool = false
    var canShow: Bool = true
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: - parent
    func updateParent(_ newValue: NotebookVM?) {
        self.parent = newValue
        self.parentId = newValue?.id
    }
    
  
}

extension NotebookVM: Equatable, Hashable {
    static func == (lhs: NotebookVM, rhs: NotebookVM) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// MARK: - children
extension NotebookVM {
    
    func setChildren(notebooks newList: [NotebookVM]?) {
        self.children = newList
    }
    
    func appendChildren(notebook newValue: NotebookVM) {
        if self.containChildNotebooks {
            self.children?.append(newValue)
        } else {
            setChildren(notebooks: [newValue])
        }
    }
    
    func insertChild(notebook newValue: NotebookVM, at position: Int) throws {
        if position <= childrenCount {
            if containChildNotebooks {
                self.children?.insert(newValue, at: position)
            } else {
                self.setChildren(notebooks: [newValue])
            }
        } else {
            throw NotebooksBusinessError.invalidPosition
        }
    }
    
    func deleteChildren(where id: UUID) {
        children?.removeAll(where: { $0.id == id })
    }
    
    var containChildNotebooks: Bool {
        childrenCount > 0
    }
    
    var childrenCount: Int {
        guard let children = children, children.count > 0 else { return 0 }
        return children.count
    }
    
    func linkSelfToChildren() {
        _ = children?.map { $0.parent = self }
    }
 
}

extension NotebookVM {
    
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
