//
//  DirectoryManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 20/05/22.
//

import Foundation

/// saves each notebook name with uuid, used to prepare hierarcy path with notebook names.
class DirectoryManager {
    
    static let shared = DirectoryManager()
    
    var fullPaths = [UUID: String]()
    
    func prepareFolderPaths() {
        
        NotebooksListBusiness.shared.prepareFolderPaths(fullPaths: &fullPaths)
    }
}
