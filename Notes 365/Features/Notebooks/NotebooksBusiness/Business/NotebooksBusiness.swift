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
    case rootAlreadyExists
}

class NotebooksBusiness {
    
    let startingOrderId = 1
    private var listSyncDate: Date = Date()
    
    private let deleteDays = 30

    var storage: NotebooksStorageProvider
    
    init(storage: NotebooksStorageProvider) {
        self.storage = storage
    }
    
    
    
    func fetchAllNotebooks() async throws -> [NotebookB] {
        return try await storage.fetchAllNotebooks()
    }
    
//    func fetchDeletedNotebooks() async -> [NotebookB] {
//        do {
//            return try await storage.fetchDeletedNotebooks()
//        } catch let err {
//            print(err)
//            return []
//        }
//    }
    
    // MARK: - Insert

//    func getNextOrderId(at siblings: [NotebookB]) -> Int {
//        if var lastOrderId = siblings.last?.orderID {
//            lastOrderId += 1
//            return lastOrderId
//        } else {
//            return startingOrderId
//        }
//    }
    
    func getRootNotebookOnly() throws -> NotebookB? {
        try storage.getRootNotebook()
    }
    
    func createRootNotebook() throws -> NotebookB {
        
        if let _ = try getRootNotebookOnly() { throw NotebooksBusinessError.rootAlreadyExists }
        let notebook = NotebookB(id: UUID(), name: "root")
        try notebook.insert(in: storage)
        return notebook
    }
    
    func createNotebook() throws -> NotebookB {
        let root = try getRootNotebookOnly() ?? createRootNotebook()
        return try createNotebook(inside: root, at: nil, children: nil)
    }
    
    func createNotebook(inside parent: NotebookB, at position: Int?, children: [NotebookB]?) throws -> NotebookB {
        // create
        let newNotebookName = generateUntitledName(atLevel: children ?? [])
        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
        newNotebook.parentId = parent.id
        // insert in hierarchy
        if let position = position {
            try parent.insertChild(id: newNotebook.id, at: position)
        } else {
            parent.appendChildren(id: newNotebook.id)
        }
        // persist
        try newNotebook.insert(in: storage)
        try parent.update(in: storage)
        
        return newNotebook
    }
    
//    func createNotebook(inside parentId: UUID, at position: Int?) throws -> NotebookB {
//        let parent = try getNotebookWithChildren(for: parentId)
//        // create
//        let newNotebookName = generateUntitledName(atLevel: parent.children ?? [])
//        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
//        newNotebook.updateParent(parent)
//        // insert in hierarchy
//        if let position = position {
//            try parent.insertChild(notebook: newNotebook, at: position)
//        } else {
//            parent.appendChildren(notebook: newNotebook)
//        }
//        // persist
//        try newNotebook.insert(in: storage)
//        try parent.update(in: storage)
//        
//        return newNotebook
//    }
    
    
    func getTopLevelNotebooksWithoutChildren() throws -> [NotebookB] {
        let notebooks = try storage.getTopLevelNotebooks()
        return notebooks
    }
   
    private func generateUntitledName(atLevel siblings: [NotebookB]) -> String {
        
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

extension NotebookB {
    
    func insert(in storage: NotebooksStorageProvider) throws {
        try storage.insert(notebook: self)
    }
    
    func update(in storage: NotebooksStorageProvider) throws {
        try storage.update(notebook: self)
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
