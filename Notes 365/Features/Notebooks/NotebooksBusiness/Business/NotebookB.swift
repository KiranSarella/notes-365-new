//
//  Models.swift
//  Notes 365
//
//  Created by kiran ipc on 14/11/23.
//

import Foundation
import SwiftData

class NotebookB: Identifiable {
    
    var id: UUID = UUID()
    var name: String = ""

    var childrenIds: [UUID]?
    
    var createdDate: Date = Date()
    var modifiedDate: Date = Date()
    var deletedDate: Date? = nil
    var parentId: UUID?
    
    var isDeleted: Bool {
        deletedDate != nil
    }
    
    init(_ notebookData: NotebookData) {
        
        self.id = notebookData.id
        self.name = notebookData.name
        self.createdDate = notebookData.createdDate
        self.modifiedDate = notebookData.modifiedDate
        self.deletedDate = notebookData.deletedDate
        
        self.parentId = notebookData.parent
        self.childrenIds = notebookData.children
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

extension NotebookB: Equatable, Hashable {
    static func == (lhs: NotebookB, rhs: NotebookB) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// MARK: - children
extension NotebookB {
    
    func setChildren(ids newList: [UUID]?) {
        self.childrenIds = newList
    }
    
    func appendChildren(id newValue: UUID) {
        if self.containChildNotebooks {
            self.childrenIds?.append(newValue)
        } else {
            setChildren(ids: [newValue])
        }
    }
    
    func insertChild(id newValue: UUID, at position: Int) throws {
        if position <= childrenCount {
            if containChildNotebooks {
                self.childrenIds?.insert(newValue, at: position)
            } else {
                self.setChildren(ids: [newValue])
            }
        } else {
            throw NotebooksBusinessError.invalidPosition
        }
    }
    
    func deleteChildren(where id: UUID) {
        childrenIds?.removeAll(where: { $0 == id })
    }
    
    var containChildNotebooks: Bool {
        childrenCount > 0
    }
    
    var childrenCount: Int {
        guard let childrenIds = childrenIds, childrenIds.count > 0 else { return 0 }
        return childrenIds.count
    }
}

