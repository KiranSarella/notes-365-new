//
//  NotebooksPathService.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation
import UIKit

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
    
    private init() { 
        observeNotebookRenamed()
        observeNotebookInserted()
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
            let fullPath = pathComponents.reversed().joined(separator: "  \u{203A}   ")
            let fullPathInfo = FullPathInfo(name: filePathInfo.name, fullPath: fullPath)
            defer {
                fullPathsCache[notebookId] = fullPathInfo
            }
            return fullPathInfo
        }
    }
    
    private func invalidateCacheFullPath() {
        fullPathsCache.removeAll()
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

// MARK: - Handle Rename
extension NotebooksPathService {
    func observeNotebookRenamed() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookRenamed(_:)), name: Notification.Name.notebookRenamed, object: nil)
    }
    
    func removeNotebookRenamedObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookRenamed, object: nil)
    }
    
    @objc func handleNotebookRenamed(_ notification: Notification) {
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let name = notification.userInfo?["name"] as? String,
            let isFolder = notification.userInfo?["isFolder"] as? Bool
        else { return }
                
        if isFolder {
            if let info = foldersPathInfo[notebookId] {
                foldersPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
            }
        } else {
            if let info = filesPathInfo[notebookId] {
                filesPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
            }
        }
        invalidateCacheFullPath()
    }
}

// MARK: - Handle Insert
extension NotebooksPathService {
    func observeNotebookInserted() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookInserted(_:)), name: Notification.Name.notebookInserted, object: nil)
    }
    
    func removeNotebookInsertedObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookInserted, object: nil)
    }
    
    @objc func handleNotebookInserted(_ notification: Notification) {
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let name = notification.userInfo?["name"] as? String,
            let isFolder = notification.userInfo?["isFolder"] as? Bool,
            let parentId = notification.userInfo?["parent_id"] as? UUID
        else { return }
                
        if isFolder {
            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
        } else {
            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
        }
        invalidateCacheFullPath()
    }
}

extension NotebooksPathService {
    func observeAppStateChanged() {
//        NotificationCenter.default.addObserver(self, selector: "asdf", name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

extension NotebookB {
    fileprivate var locationInfo: LocationInfo {
        LocationInfo(parentId: parentId, name: name)
    }
}
