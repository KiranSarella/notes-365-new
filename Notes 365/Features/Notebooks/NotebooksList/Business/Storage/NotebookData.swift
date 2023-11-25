//
//  Notebook.swift
//  Notes 365
//
//  Created by Kiran Sarella on 15/11/22.
//

import UIKit
import SwiftData

@Model
class NotebookData {
    
    var id: UUID = UUID()
    var name: String = ""
    var parent: UUID?
    var isFolder: Bool = false
    
    var createdDate: Date = Date()
    var deletedDate: Date?
    var modifiedDate: Date = Date()
    
    var isDeleted: Bool {
        deletedDate != nil
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        
        createdDate = Date()
        deletedDate = nil
        modifiedDate = Date()
    }
}

extension NotebookData {
    func sync(from newData: NotebookData) {
        self.parent = newData.parent
        self.isFolder = newData.isFolder
        self.name = newData.name
        self.deletedDate = newData.deletedDate
        self.modifiedDate = newData.modifiedDate
    }
}

extension NotebookData: CustomStringConvertible {
    var description: String {
        "\(id.uuidString), \(name), pid: \(parent?.uuidString ?? "nil"), isFolder: \(isFolder)"
    }
}
