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
    
    var document: NoteDocument?
    
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
    
   
    
    var fileURL: URL {
        let path = Constants.notebooksPath + "/" + filePath
        let basePathUrl = EnvironmentState.shared.basePathURL!
        let fileURL = basePathUrl.appendingPathComponent(path)
        print(fileURL)
        return fileURL
    }
    
    
}

// MARK: - UIDocument operations
extension Notebook {
    
    func readDocument() async -> String? {
        print(#function)
        document = await NoteDocument(fileURL: fileURL)
        await document?.open()
        return await document?.content
    }
    
    func updateDocument(with content: String) {
        guard let document = document else { return }
        document.updateChangeCount(.done)
    }
    
    func saveDocument(with content: String) async {
        print(#function)
        guard let document = document else { return }
        
        await document.setContentChanges(newContent: content)
        let status = await document.save(to: fileURL, for: .forOverwriting)
        print(status)
    }
    
    func closeDocument() async {
        print(#function)
        guard let document = document else { return }
        await document.close()
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
    
    
//    var directoryPath: String {
//
//        // add parents
//        var parentRef = self.parent
//        if parentRef == nil {
//            return ""
//        } else {
//            var path = parentRef!.name
//            parentRef = parentRef!.parent
//            while parentRef != nil {
//                path = parentRef!.name + "/" + path
//                parentRef = parentRef?.parent
//            }
//            // return
//            return path
//        }
//    }
}


extension Notebook {
    
    func loadContent() -> String {
        let fullPath = Constants.notebooksPath + "/" + self.id.uuidString + ".md"
        return FilesHelper.shared.readFile(from: fullPath) ?? ""
    }
}
