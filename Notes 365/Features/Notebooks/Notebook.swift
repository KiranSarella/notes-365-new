//
//  Notebook.swift
//  Notes 365
//
//  Created by Kiran Sarella on 15/11/22.
//

import SwiftUI

@Observable
class Notebook: Identifiable, Codable {
//    var id: Self { self }
    var id: UUID = UUID()
    var name: String = "" {
        didSet {
            NotificationCenter.default.post(name: .notebookChangeNotification, object: nil)
        }
    }
    
//    var child: [Notebook]? = nil
    
    var children: [Notebook]? = nil
    
    unowned var parent: Notebook? = nil
    
//    var document: MarkdownDocument?
    var isResolvingConflicts = false
    var newContentAvailalble: (()->())? = nil
    private var notificationObserver: Any? = nil
    
    var content: String = ""
    var isExpanded: Bool = false
    var isDeleted = false
    var canShow = true
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    required convenience init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try! container.decode(UUID.self, forKey: .id)
        let name = try! container.decode(String.self, forKey: .name)
        
        self.init(id: id, name: name)
        
        let nested = try? container.decode([Notebook].self, forKey: .friends)
        print(nested)
        if nested != nil && nested!.isEmpty == false {
            children = nested
        }
        
        if let children = children {
            // set parent reference
            for child in children {
                child.parent = self
            }
        }
        
    }
    
    var containChildNotebooks: Bool {
        
        guard let children = children, children.count > 0 else { return false }
        
        return true
    }
    
    var fileURL: URL {
        let path = Constants.notebooksFolderName + "/" + filePath
        let basePathUrl = EnvironmentState.shared.basePathURL!
        let fileURL = basePathUrl.appendingPathComponent(path)
//        print(fileURL)
        return fileURL
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
    
    var path: [String] {
        
        var uuids = [String]()
        // add self
        uuids.append(self.id.uuidString)
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            uuids.append(parentRef!.id.uuidString)
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
}


extension Notebook {
    
    nonisolated func loadContent() async -> String? {
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            guard
                let data = try fileHandle.readToEnd(),
                let readString = String(data: data, encoding: .utf8) else { return nil }
            
            fileHandle.closeFile()
            return readString
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
    
    func saveContent(content: String) {
        do {
            // Write to the file
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
}
