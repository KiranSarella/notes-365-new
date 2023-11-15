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
//    func insertNotebook(at position: Int) throws -> Notebook {
//        
//    }
    
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
        if parent.containChildNotebooks {
            if let position = position {
                if position > parent.childrenCount {
                    parent.insertChild(notebook: newNotebook, at: position)
                } else {
                    throw NotebooksBusinessError.invalidPosition
                }
            } else {
                parent.appendChildren(notebook: newNotebook)
            }
        } else {
            parent.setChildren(notebooks: [newNotebook])
        }
        // persist
        try newNotebook.insert(in: storage)
        try parent.update(in: storage)
        
        return newNotebook
    }
    
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
