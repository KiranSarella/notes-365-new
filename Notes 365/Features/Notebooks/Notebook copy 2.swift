//
//  Notebook.swift
//  Notes 365
//
//  Created by Kiran Sarella on 15/11/22.
//

import UIKit
import SwiftData

@Observable
class Notebook: Identifiable {
    
    var id: UUID = UUID()
    var name: String = ""
//    @Relationship(inverse: \Notebook.parent)
//    @Relationship(.cascade)
    @Relationship
    var children: [Notebook]?
    
    var createdDate: Date = Date()
    var deletedDate: Date?
    var modifiedDate: Date = Date()
    
    var orderID: Int = 0
//    unowned var parent: Notebook?
    @Relationship(inverse: \Notebook.children)
    var parent: Notebook?
    
    var isExpanded: Bool = false
    var isDeleted: Bool = false
    var canShow: Bool = true
    
    func sortChildren() {
        if children != nil {
            children!.sort(by: { n1, n2 in
                n1.orderID < n2.orderID
            })
            
            // apply to nested
            for i in 0..<children!.count {
                children![i].sortChildren()
            }
        }
    }
    
    func onlySelfSortChildren() {
        if children != nil {
            
            print("## before")
            for c in children! {
                print(c.orderID)
            }
//            
//            children!.sort(by: { n1, n2 in
//                n1.orderID < n2.orderID
//            })
//            
//            print("## after")
//            for c in children! {
//                print(c.orderID)
//            }
            
            print("# manual")
            if let sortedArr = children?.sorted(by: { $0.orderID < $1.orderID }) {
                
                children = sortedArr
                
                for c in sortedArr {
                    print(c.orderID)
                }
                print("---")
                for c in children! {
                    print(c.orderID)
                }
            }
            
        }
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        
        createdDate = Date()
        deletedDate = nil
        modifiedDate = Date()
        
        isExpanded = false
        isDeleted = false
        canShow = true
    }
    
    
//    required convenience init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let id = try! container.decode(UUID.self, forKey: .id)
//        let name = try! container.decode(String.self, forKey: .name)
//        
//        self.init(id: id, name: name)
//        
//        do {
//            createdDate = try container.decode(Date.self, forKey: .createdDate)
//        } catch {
//            let date = (try? FileManager.default.attributesOfItem(atPath: fileURL.path(percentEncoded: false)))?[.creationDate] as? Date
//            
//            createdDate = date ?? Date()
//        }
//        
//        do {
//            modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
//        } catch {
//            let date = (try? FileManager.default.attributesOfItem(atPath: fileURL.path(percentEncoded: false)))?[.modificationDate] as? Date
//            
//            modifiedDate = date ?? Date()
//        }
//        
//        deletedDate = try? container.decode(Date.self, forKey: .deletedDate)
//        
//        children = try? container.decode([Notebook].self, forKey: .friends)
//        
//        // set parent reference
//        if let children = children {
//            for child in children {
//                child.parent = self
//            }
//        }
//        
////        NotebooksCache.shared.flatNotebooks[self.id.uuidString] = self
//    }
    
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


//extension Notebook {
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case friends
//        case createdDate
//        case modifiedDate
//        case deletedDate
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(children, forKey: .friends)
//        try container.encode(createdDate, forKey: .createdDate)
//        try container.encode((modifiedDate), forKey: .modifiedDate)
//        try container.encode(deletedDate, forKey: .deletedDate)
//    }
//}

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
    
    var folderPaths: [String] {
        // add self
        var paths = [self.name]
        // add parents
        var parentRef = self.parent
        while parentRef != nil {
            paths.append(parentRef!.name)
            // next
            parentRef = parentRef?.parent
        }
        // return
        return paths
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
