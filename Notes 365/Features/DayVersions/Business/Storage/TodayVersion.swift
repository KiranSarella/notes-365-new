//
//  TodayVersion.swift
//  Notes 365
//
//  Created by kiran ipc on 26/09/23.
//

import Foundation
import SwiftData

@Model
class TodayVersion {
    var id: String {
        "\(date.string(format: "yyyy-MM-dd"))-\(notebookID)"
    }
    var notebookID: UUID = UUID()
    var content: String = ""
    var date: Date = DateTime.now()
    
    init(notebookID: UUID, content: String = "") {
        self.notebookID = notebookID
        self.content = content
    }
}

