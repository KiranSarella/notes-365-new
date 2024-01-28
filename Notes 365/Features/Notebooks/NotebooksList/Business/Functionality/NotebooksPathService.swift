//
//  NotebooksPathService.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation
import UIKit

struct LocationInfo: Hashable {
    let parentId: UUID?
    let name: String
}

struct FullPathInfo: Hashable {
    let id: UUID
    let name: String
    let fullPath: String
}

class NotebooksPathService {
    static let shared = NotebooksPathService()
    let notebooksBusiness = BusinessFactory.createNotebooksFactory()
    
    fileprivate var filesPathInfo = [UUID: LocationInfo]()
    fileprivate var foldersPathInfo = [UUID: LocationInfo]()
    fileprivate var foldersInfoCache: Set<NotebookB> = []
    fileprivate var filesInfoCache: Set<NotebookB> = []
    
    var foldersPathsCache = [UUID: String]()
    var filesPathsCache = [UUID: String]()
    
    private(set) var isLoaded = false
    var cloudSyncFinishedObserver: NSObjectProtocol?
    
    
    private init() {
        observeNotebookRenamed()
        observeNotebookInserted()
        observeNotebookMoved()
        observeCloudFinished()
    }
    
    deinit {
        removeNotebookRenamedObserver()
        removeNotebookMovedObserver()
        removeNotebookInsertedObserver()
    }
    
    func refreshOnNextService() {
        isLoaded = false
    }
    
    func refreshNotebooksInfo() async {
        if isLoaded {
            return
        }
        resetInfoObjects()
        await updateNotebooksInfo()
        isLoaded = true
    }
    
    func resetInfoObjects() {
        filesPathInfo.removeAll()
        foldersPathInfo.removeAll()
        foldersInfoCache.removeAll()
        filesInfoCache.removeAll()
    }
    
    private func updateNotebooksInfo() async {
        return await withCheckedContinuation { c in
            let results = notebooksBusiness.getAllFilesInfo()
            for result in results {
                if result.isFolder {
                    foldersPathInfo[result.id] = result.locationInfo()
                    foldersInfoCache.insert(result)
                } else {
                    filesPathInfo[result.id] = result.locationInfo()
                    filesInfoCache.insert(result)
                }
            }
            c.resume()
        }
    }
    
    func fileName(for notebookId: UUID) -> String? {
        if let name = filesPathInfo[notebookId]?.name {
            return name
        } else {
            isLoaded = false
            return nil
        }
    }
    
    func folderFullPath(for notebookId: UUID) -> String? {
        if let fullPathInfo = foldersPathsCache[notebookId] {
            logger.debug("cached - \(fullPathInfo)")
            return fullPathInfo
        } else {
            let newPath = generateFolderFullPath(notebookId: notebookId)
            if let newPath = newPath {
                foldersPathsCache[notebookId] = newPath
            }
            logger.debug("generated - \(newPath ?? "")")
            return newPath
        }
    }
    
    func fullPath(for notebookId: UUID) -> String? {
        if let fullPathInfo = filesPathsCache[notebookId] {
            logger.debug("cached - \(fullPathInfo)")
            return fullPathInfo
        } else {
            let newPath = generateFullPath(notebookId: notebookId)
            if let newPath = newPath {
                filesPathsCache[notebookId] = newPath
            }
            logger.debug("generated - \(newPath ?? "")")
            return newPath
        }
    }
    
    private func generateFolderFullPath(notebookId: UUID) -> String? {
        if let filePathInfo = self.foldersPathInfo[notebookId] {
            var pathComponents = [String]()
            pathComponents.append(filePathInfo.name)
            if let folderId = filePathInfo.parentId {
                appendFoldersPath(startingFrom: folderId, in: &pathComponents)
            }
            let fullPath = pathComponents.reversed().joined(separator: "  \u{203A}  ")
            return fullPath
        } else {
            return nil
        }
    }
    
    
    private func generateFullPath(notebookId: UUID) -> String? {
        if let filePathInfo = self.filesPathInfo[notebookId] {
            var pathComponents = [String]()
            pathComponents.append(filePathInfo.name)
            if let folderId = filePathInfo.parentId {
                appendFoldersPath(startingFrom: folderId, in: &pathComponents)
            }
            let fullPath = pathComponents.reversed().joined(separator: "  \u{203A}  ")
            return fullPath
        } else {
            return nil
        }
    }
    
    private func invalidateCacheFullPath() {
        filesPathsCache.removeAll()
        foldersPathsCache.removeAll()
    }
    
    private func appendFoldersPath(startingFrom folderId: UUID, in pathComponents: inout [String]) {
        guard let folderPathInfo = foldersPathInfo[folderId] else { return }
        pathComponents.append(folderPathInfo.name)
        if let parentId = folderPathInfo.parentId {
            appendFoldersPath(startingFrom: parentId, in: &pathComponents)
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
            let isFolder = notification.userInfo?["isFolder"] as? Bool
        else { return }
                
        let parentId = notification.userInfo?["parent_id"] as? UUID
        
        let notebookB = NotebookB(id: notebookId, name: name)
        notebookB.isFolder = isFolder
        notebookB.parentId = parentId
        
        if isFolder {
            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
            foldersInfoCache.insert(notebookB)
        } else {
            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
            filesInfoCache.insert(notebookB)
        }
        invalidateCacheFullPath()
    }
}

// MARK: - Handle move - using insert logic
extension NotebooksPathService {
    func observeNotebookMoved() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookMoved(_:)), name: Notification.Name.notebooksMoved, object: nil)
    }

    func removeNotebookMovedObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebooksMoved, object: nil)
    }
    
    @objc func handleNotebookMoved(_ notification: Notification) {
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let name = notification.userInfo?["name"] as? String,
            let isFolder = notification.userInfo?["isFolder"] as? Bool
        else { return }
                
        let parentId = notification.userInfo?["parent_id"] as? UUID
        
        let notebookB = NotebookB(id: notebookId, name: name)
        notebookB.isFolder = isFolder
        notebookB.parentId = parentId
        
        if isFolder {
            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
            foldersInfoCache.remove(notebookB)
            foldersInfoCache.insert(notebookB)
        } else {
            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
            filesInfoCache.remove(notebookB)
            filesInfoCache.insert(notebookB)
        }
        invalidateCacheFullPath()
    }
}

extension NotebooksPathService {
//    func observeAppStateChanged() {
////        NotificationCenter.default.addObserver(self, selector: "asdf", name: UIApplication.willEnterForegroundNotification, object: nil)
//    }
}

extension NotebookB {
    
    func locationInfo() -> LocationInfo {
        LocationInfo(parentId: parentId, name: name)
    }
    
//    fileprivate var locationInfo: LocationInfo {
//        LocationInfo(parentId: parentId, name: name)
//    }
}


extension NotebooksPathService {
    
    func observeCloudFinished() {
        cloudSyncFinishedObserver = NotificationCenter.default.addObserver(forName: .icloudSyncFinished, object: nil, queue: .main) { [weak self] notification in
            self?.isLoaded = false
        }
    }
}


// MARK: - Get all child items
extension NotebooksPathService {
    
    func getAllChildFilesAndFolders(folderId: UUID) -> ([UUID], [UUID]) {
        var recentsFilesToRemove = [UUID]()
        var recentsFoldersToRemove = [UUID]()
        // add selected folder
        recentsFoldersToRemove.append(folderId)
        // add child folders and files
        getChildFoldersAndFiles(folderId: folderId, &recentsFilesToRemove, &recentsFoldersToRemove)
        
        return (recentsFilesToRemove, recentsFoldersToRemove)
    }
    
    func getChildFoldersAndFiles(folderId: UUID, _ recentsFilesToRemove: inout [UUID], _ recentsFoldersToRemove: inout [UUID]) {
        // add all child files
        let filesIds = filesInfoCache
                        .filter { info in info.parentId == folderId }
                        .map { $0.id }
        recentsFilesToRemove.append(contentsOf: filesIds)
        
        // add all child folders
        let subfolderIds = foldersInfoCache
                        .filter { info in info.parentId == folderId }
                        .map { $0.id }
        recentsFoldersToRemove.append(contentsOf: subfolderIds)
        
        // for each folder again resursively add its childs
        for subfolderId in subfolderIds {
            getChildFoldersAndFiles(folderId: subfolderId, &recentsFilesToRemove, &recentsFoldersToRemove)
        }
    }
}
