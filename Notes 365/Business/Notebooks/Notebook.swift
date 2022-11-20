//
//  Notebook.swift
//  Notes 365
//
//  Created by Kiran Sarella on 15/11/22.
//

import Foundation


class Notebook: Identifiable, Codable {
    
    var id: UUID
    var name: String {
        didSet {
            NotificationCenter.default.post(name: .notebookChangeNotification, object: nil)
//            onNameChange?(name)
        }
    }
    var children: [Notebook]?
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    required convenience init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try! container.decode(UUID.self, forKey: .id)
        let name = try! container.decode(String.self, forKey: .name)
        
        self.init(id: id, name: name)
        
        children = try? container.decode([Notebook].self, forKey: .friends)
    }
    
    var containChildNotebooks: Bool {
        children != nil ? true : false
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


extension Notebook {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case friends
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(children, forKey: .friends)
    }
}
