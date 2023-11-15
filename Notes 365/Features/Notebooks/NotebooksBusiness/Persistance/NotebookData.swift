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
    var parent: UUID?
    var name: String = ""
    var orderID: Int = 0
    
    var children: [UUID]?
    
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
