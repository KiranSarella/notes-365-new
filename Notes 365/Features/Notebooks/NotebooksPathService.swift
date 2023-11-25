//
//  NotebooksPathService.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation

fileprivate struct LocationInfo {
    let parentId: UUID?
    let name: String
}

struct FullPathInfo {
    let name: String
    let fullPath: String
}

class NotebooksPathService {
    static let shared = NotebooksPathService()
    
    fileprivate var filesPathInfo = [UUID: LocationInfo]()
    fileprivate var foldersPathInfo = [UUID: LocationInfo]()
    
    var fullPathsCache = [UUID: FullPathInfo]()
    
    var isLoaded = false
    
    init() {
//        updateInfo()
    }
    
    func path(for notebookId: UUID) -> FullPathInfo? {
        if let fullPathInfo = fullPathsCache[notebookId] {
            return fullPathInfo
        } else {
            guard let filePathInfo = filesPathInfo[notebookId] else { return nil }
            var pathComponents = [String]()
            pathComponents.append(filePathInfo.name)
            if let folderId = filePathInfo.parentId {
                appendFoldersPath(startingFrom: folderId, in: &pathComponents)
            }
            let fullPath = pathComponents.joined(separator: "  \u{203A}   ")
            let fullPathInfo = FullPathInfo(name: filePathInfo.name, fullPath: fullPath)
            defer {
                fullPathsCache[notebookId] = fullPathInfo
            }
            return fullPathInfo
        }
    }
    
    private func appendFoldersPath(startingFrom folderId: UUID, in pathComponents: inout [String]) {
        guard let folderPathInfo = foldersPathInfo[folderId] else { return }
        pathComponents.append(folderPathInfo.name)
        if let parentId = folderPathInfo.parentId {
            appendFoldersPath(startingFrom: parentId, in: &pathComponents)
        }
    }
    
    func refreshNotebooksInfo() async {
        if isLoaded {
            return
        }
        updateNotebooksInfo()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isLoaded = true
    }
    
    private func updateNotebooksInfo() {
        let notebooksBusiness = BusinessFactory.createNotebooksFactory()
        let results = notebooksBusiness.getAllFilesInfo()
        for result in results {
            if result.isFolder {
                foldersPathInfo[result.id] = result.locationInfo
            } else {
                filesPathInfo[result.id] = result.locationInfo
            }
        }
    }
}


extension NotebookB {
    fileprivate var locationInfo: LocationInfo {
        LocationInfo(parentId: parentId, name: name)
    }
}
