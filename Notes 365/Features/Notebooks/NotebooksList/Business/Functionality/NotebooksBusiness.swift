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
    
    private let deleteDays = 30

    var storage: NotebooksStorageProvider
    
    init(storage: NotebooksStorageProvider) {
        self.storage = storage
    }
    
    func fetchAllNotebooks() async throws -> [NotebookB] {
        return try await storage.fetchAllNotebooks()
    }

    func getRootNotebookOnly() throws -> NotebookB? {
        try storage.getRootNotebook()
    }
    
    func createRootNotebook() throws -> NotebookB {
        if let _ = try getRootNotebookOnly() { throw NotebooksBusinessError.rootAlreadyExists }
        let notebook = NotebookB(id: UUID(), name: "root")
        try notebook.insert(in: storage)
        return notebook
    }
    
    func createFolder(inside parent: NotebookB, siblings: [NotebookB]) throws -> NotebookB {
        // create
        let newNotebookName = generateUntitledName(atLevel: siblings, prefix: "Folder")
        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
        newNotebook.parentId = parent.id
        newNotebook.isFolder = true
        try newNotebook.insert(in: storage)
        return newNotebook
    }
    
    func createFile(inside parent: NotebookB, siblings: [NotebookB]) throws -> NotebookB {
        // create
        let newNotebookName = generateUntitledName(atLevel: siblings, prefix: "Notebook")
        let newNotebook = NotebookB(id: UUID(), name: newNotebookName)
        newNotebook.parentId = parent.id
        newNotebook.isFolder = false
        try newNotebook.insert(in: storage)
        return newNotebook
    }
    
    func getNotebook(id: UUID) throws -> NotebookB {
        return try storage.getNotebook(for: id)
    }
    
    func fetchItems(at parent: UUID) throws -> [NotebookB] {
        return try storage.getActiveChildren(forParent: parent)
    }
    
    func getTopLevelNotebooksWithoutChildren() throws -> [NotebookB] {
        let notebooks = try storage.getTopLevelNotebooks()
        return notebooks
    }
   
    private func generateUntitledName(atLevel siblings: [NotebookB], prefix: String) -> String {
        
        var fileNameAlreadyExists: Bool {
            siblings.contains(where: { $0.name == fileName })
        }
        
        var fileName = ""
        let nameGenerator = NameGenerator(prefix: prefix)
        if siblings.isEmpty {
            fileName = nameGenerator.generateName()
        } else {
            repeat {
                fileName = nameGenerator.generateName()
            } while fileNameAlreadyExists
        }
        return fileName
    }
    
    func deleteNotebook(notebook: NotebookB) throws {
        notebook.deletedDate = Date()
        try notebook.update(in: storage)
    }
    
    private func isAlreadyFilenameExists(fileName: String, in siblings: [NotebookB]) -> Bool {
        return siblings.contains(where: { $0.name == fileName })
    }
    
    func rename(notebook: NotebookB, newValue: String, siblings: [NotebookB]) throws {
        if isAlreadyFilenameExists(fileName: newValue, in: siblings) {
            throw NotebookBusinessError.alreadyExists
        }
        notebook.name = newValue
        try notebook.update(in: storage)
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

extension NotebooksBusiness {
    
    func getAllFilesInfo() -> [NotebookB] {
        return (try? storage.getAllFilesInfo()) ?? []
    }
}

