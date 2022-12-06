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
        }
    }
    var children: [Notebook]?
    unowned var parent: Notebook?
    
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
        
        // set parent reference
        if let children = children {
            for child in children {
                child.parent = self
            }
        }
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
        // add self
        var path: String = self.name + ".md"
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            path = parentRef!.name + "/" + path
            parentRef = parentRef?.parent
        }
        // base path
        path = "notebooks" + "/" + path
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
        // base path
        path = "notebooks" + "/" + path
        // return
        return path
    }
    
    
    var directoryPath: String {
        
        // add parents
        var parentRef = self.parent
        if parentRef == nil {
            return "notebooks"
        } else {
            var path = parentRef!.name
            parentRef = parentRef!.parent
            while parentRef != nil {
                path = parentRef!.name + "/" + path
                parentRef = parentRef?.parent
            }
            // base path
            path = "notebooks" + "/" + path
            // return
            return path
        }
    }
}


extension Notebook {
    
    func loadContent() -> String {
        
        let fullPath = self.folderPath + ".md"
//        print(fullPath)
        return FilesHelper.shared.readFile(from: fullPath) ?? ""
    }
}
