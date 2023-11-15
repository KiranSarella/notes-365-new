//
//  NotebookContent.swift
//  Notes 365
//
//  Created by kiran ipc on 25/09/23.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class NotebookContent: Identifiable, Codable {
    
    var notebookID: UUID = UUID()
    var content: String = ""
    
    init(notebookID: UUID, content: String = "") {
        self.notebookID = notebookID
        self.content = content
    }
    
    required convenience init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let notebookID = try! container.decode(UUID.self, forKey: .notebookID)
        let content = try! container.decode(String.self, forKey: .content)
        
        self.init(notebookID: notebookID, content: content)
    }
    
    
}

extension NotebookContent: Equatable, Hashable {
    static func == (lhs: NotebookContent, rhs: NotebookContent) -> Bool {
        return lhs.notebookID == rhs.notebookID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(notebookID)
    }
}


extension NotebookContent {

    enum CodingKeys: String, CodingKey {
        case notebookID
        case content
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(notebookID, forKey: .notebookID)
        try container.encode(content, forKey: .content)
    }
}
