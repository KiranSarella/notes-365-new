//
//  RecentItem.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation
import SwiftData

@Model
class RecentItemData {
    var id: UUID = UUID()
    var name: String = ""
    var isFolder: Bool = false
    var updatedDate: Date = DateTime.now()
    
    init(id: UUID, name: String, isFolder: Bool, updatedDate: Date) {
        self.id = id
        self.name = name
        self.isFolder = isFolder
        self.updatedDate = updatedDate
    }
}
