
import Foundation
//
//  Notebook.swift
//  Notes 365
//
//  Created by Kiran Sarella on 15/11/22.
//

import SwiftUI

class NotebookOld: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var children: [NotebookOld]? = nil
    unowned var parent: NotebookOld? = nil
    var newContentAvailalble: (()->())? = nil
    private var notificationObserver: Any? = nil
    var content: String = ""
    var isExpanded: Bool = false
    var isDeleted = false
    var canShow = true
    var folderId: UUID?
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try! container.decode(UUID.self, forKey: .id)
        let name = try! container.decode(String.self, forKey: .name)
        self.init(id: id, name: name)
        let nested = try? container.decode([NotebookOld].self, forKey: .friends)
        if nested != nil && nested!.isEmpty == false {
            children = nested
        }
        if let children = children {
            // set parent reference
            for child in children {
                child.parent = self
            }
        }
        NotebooksCache.shared.flatNotebooks[self.id.uuidString] = self
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

extension NotebookOld: Equatable, Hashable {
    static func == (lhs: NotebookOld, rhs: NotebookOld) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension NotebookOld {

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

extension NotebookOld {
    
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


extension NotebookOld {
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
