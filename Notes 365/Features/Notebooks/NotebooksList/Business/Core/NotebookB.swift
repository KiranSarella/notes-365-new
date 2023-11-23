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
    var parentId: UUID?
    var isFolder: Bool = false
    
    var createdDate: Date = Date()
    var modifiedDate: Date = Date()
    var deletedDate: Date? = nil
    
    var isDeleted: Bool {
        deletedDate != nil
    }
    
    init(_ notebookData: NotebookData) {
        self.id = notebookData.id
        self.name = notebookData.name
        self.parentId = notebookData.parent
        self.isFolder = notebookData.isFolder
        self.createdDate = notebookData.createdDate
        self.modifiedDate = notebookData.modifiedDate
        self.deletedDate = notebookData.deletedDate
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

