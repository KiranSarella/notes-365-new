//
//  NotebooksBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import UIKit
import SwiftData

public enum NotebooksBusinessError: Error {
    case invalidPosition
}

class NotebooksBusiness {
    
    let startingOrderId = 1
    private var listSyncDate: Date = Date()
    
    private let deleteDays = 30

    var storage: NotebooksStorageProvider
    
    init(storage: NotebooksStorageProvider) {
        self.storage = storage
    }
    
    func fetchNotebooks() async -> [Notebook] {
        do {
            return try await storage.fetchNotebooks()
        } catch let err {
            print(err)
            return []
        }
    }
    
    func fetchDeletedNotebooks() async -> [Notebook] {
        do {
            return try await storage.fetchDeletedNotebooks()
        } catch let err {
            print(err)
            return []
        }
    }
    
    // MARK: - Insert

    func getNextOrderId(at siblings: [Notebook]) -> Int {
        if var lastOrderId = siblings.last?.orderID {
            lastOrderId += 1
            return lastOrderId
        } else {
            return startingOrderId
        }
    }
    
    func createNotebook() throws -> Notebook {
        // get top level notebooks
        let siblings = try getTopLevelNotebooksWithoutChildren()
        let notebook = Notebook(id: UUID(), name: generateUntitledName(atLevel: siblings))
        notebook.orderID = getNextOrderId(at: siblings)
        try notebook.insert(in: storage)
        return notebook
    }
    
    func createNotebook(inside parentId: UUID, at position: Int?) throws -> Notebook {
        let parent = try getNotebook(for: parentId)
        // create
        let newNotebookName = generateUntitledName(atLevel: parent.children ?? [])
        let newNotebook = Notebook(id: UUID(), name: newNotebookName)
        newNotebook.updateParent(parent)
        // insert in hierarchy
        if let position = position {
            try parent.insertChild(notebook: newNotebook, at: position)
        } else {
            parent.appendChildren(notebook: newNotebook)
        }
        // persist
        try newNotebook.insert(in: storage)
        try parent.update(in: storage)
        
        return newNotebook
    }
    
//    func createNotebook(below position: Int) throws -> Notebook {
//        // get top level notebooks
//        // create new notebook at postion
//        // insert at position
//        // update orderID for each after element
//        // save all
//        
//        let topLevelList = try getTopLevelNotebooksWithoutChildren()
//        
//        if position < topLevelList.count {
//            let newNotebook = Notebook(id: UUID(), name: generateUntitledName(atLevel: topLevelList))
//            newNotebook.orderID = topLevelList[position].orderID + 1
//            try newNotebook.insert(in: storage)
//            
//            for i in position..<topLevelList.count {
//                
//            }
//            
//            
//        } else if position == topLevelList.count {
//            // append at last
//            return try createNotebook()
//        }
//        else {
//            throw NotebooksBusinessError.invalidPosition
//        }
//        
//
//        
//    }
    
    func getNotebook(for id: UUID) throws -> Notebook {
        let notebook = try storage.getNotebook(for: id)
        try notebook.populateChildren(from: storage)
        notebook.linkSelfToChildren()
        return notebook
    }
    
    func getTopLevelNotebooksWithoutChildren() throws -> [Notebook] {
        let notebooks = try storage.getTopLevelNotebooks()
        return notebooks
    }
   
    private func generateUntitledName(atLevel siblings: [Notebook]) -> String {
        
        var fileNameAlreadyExists: Bool {
            siblings.contains(where: { $0.name == fileName })
        }
        
        var fileName = ""
        let nameGenerator = NameGenerator(prefix: "Notebook")
        if siblings.isEmpty {
            fileName = nameGenerator.generateName()
        } else {
            repeat {
                fileName = nameGenerator.generateName()
            } while fileNameAlreadyExists
        }
        return fileName
    }
    
    
}

extension Notebook {
    
    func insert(in storage: NotebooksStorageProvider) throws {
        try storage.insert(notebook: self)
    }
    
    func update(in storage: NotebooksStorageProvider) throws {
        try storage.update(notebook: self)
    }
    
    func populateChildren(from storage: NotebooksStorageProvider) throws {
        setChildren(notebooks: try storage.getChildren(forParent: id))
    }
    
}

class NameGenerator {
    let prefix: String
    var sequence: Int
    
    init(prefix: String, sequence: Int = 1) {
        self.prefix = prefix
        self.sequence = sequence
    }
    
    func generateName() -> String {
        defer { sequence += 1 }
        return "\(prefix) \(sequence)"
    }
}
