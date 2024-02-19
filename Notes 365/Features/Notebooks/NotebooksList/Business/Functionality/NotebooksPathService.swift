//
//  NotebooksPathService.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation
import UIKit
import Combine

struct LocationInfo: Hashable {
    let parentId: UUID?
    let name: String
}

struct FullPathInfo: Hashable {
    let id: UUID
    let name: String
    let fullPath: String
}

actor NotebooksPathService {
    static let shared = NotebooksPathService()
    let notebooksBusiness = BusinessFactory.createNotebooksFactory()
    
    fileprivate var filesPathInfo = [UUID: LocationInfo]()
    fileprivate var foldersPathInfo = [UUID: LocationInfo]()
    fileprivate var foldersInfoCache: Set<NotebookB> = []
    fileprivate var filesInfoCache: Set<NotebookB> = []
    
    var foldersPathsCache = [UUID: String]()
    var filesPathsCache = [UUID: String]()
    
    private(set) var isRefreshing = false
    var cloudSyncFinishedObserver: NSObjectProtocol?
    
    var isEmpty: Bool {
        foldersPathInfo.isEmpty && filesPathInfo.isEmpty
    }
    
    var observingServices = false
    
    var lastRefreshTime: Date?
    
    var renamedObserver: Cancellable?
    var insertedObserver: Cancellable?
    var movedObserver: Cancellable?
    var cloudSyncFinishObserver: Cancellable?
    
    private init() {
        
    }
    
    
    
    func startObservingServices() {
        if observingServices {
            return
        }
        
        observingServices = true
        
        observeNotebookRenamed()
        observeNotebookInserted()
        observeNotebookMoved()
        observeCloudFinished()
    }
    
    func stopObservingServices() {
        if observingServices == false {
            return
        }

        observingServices = false
        
        renamedObserver?.cancel()
        renamedObserver = nil
        
        insertedObserver?.cancel()
        insertedObserver = nil
        
        movedObserver?.cancel()
        movedObserver = nil
        
        cloudSyncFinishObserver?.cancel()
        cloudSyncFinishObserver = nil
        
//        removeNotebookRenamedObserver()
//        removeNotebookMovedObserver()
//        removeNotebookInsertedObserver()
    }
    
    deinit {
//        stopObservingServices()
    }
    
    var refreshTask: Task<(), Never>?
    
    func doRefresh() {
        if isRefreshing { return }
        refreshTask = Task {
            await refreshNotebooksInfo()
        }
    }
    
    func doRefreshIfNotLoaded() async {
        logger.debug("\(#function)")
        if isEmpty && isRefreshing == false {
            await refreshNotebooksInfo()
        }
    }
    
    func refreshNotebooksInfo() async {
        logger.debug("\(#function)")
        isRefreshing = true
        lastRefreshTime = DateTime.now()
        logger.debug("lastRefreshTime: \(self.lastRefreshTime?.debugDescription ?? "")")
        resetInfoObjects()
        updateNotebooksInfo()
        isRefreshing = false
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func resetInfoObjects() {
        filesPathInfo.removeAll()
        foldersPathInfo.removeAll()
        foldersInfoCache.removeAll()
        filesInfoCache.removeAll()
    }
    
    private func updateNotebooksInfo() {
        logger.debug("\(#function)")
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
    }
    
//    private func updateNotebooksInfo() async {
//        return await withCheckedContinuation { c in
//            logger.debug("\(#function)")
//            let results = notebooksBusiness.getAllFilesInfo()
//            for result in results {
//                if result.isFolder {
//                    foldersPathInfo[result.id] = result.locationInfo()
//                    foldersInfoCache.insert(result)
//                } else {
//                    filesPathInfo[result.id] = result.locationInfo()
//                    filesInfoCache.insert(result)
//                }
//            }
//            c.resume()
//        }
//    }
    
    func fileName(for notebookId: UUID) -> String? {
        if let name = filesPathInfo[notebookId]?.name {
            return name
        } else {
//            isLoaded = false
            return nil
        }
    }
    
    func folderFullPath(for notebookId: UUID) async -> String? {
        
        if isRefreshing {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
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
    
//    func fullPath(for notebookId: UUID) async -> String? {
//        return await withCheckedContinuation { c in
//            if isLoaded == false {
//                
//                try? await Task.sleep(nanoseconds: 1_000_000_000)
//            }
//            
//            if let fullPathInfo = filesPathsCache[notebookId] {
//                logger.debug("cached - \(fullPathInfo)")
//                c.resume(returning: fullPathInfo)
//            } else {
//                let newPath = generateFullPath(notebookId: notebookId)
//                if let newPath = newPath {
//                    filesPathsCache[notebookId] = newPath
//                }
//                logger.debug("generated - \(newPath ?? "")")
//                c.resume(returning: newPath)
//            }
//        }
//    }
    
    func fileFullPath(for notebookId: UUID) async -> String? {
        
        if isRefreshing {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
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

    
//    func fullPath(for notebookId: UUID) -> String? {
//        if let fullPathInfo = filesPathsCache[notebookId] {
//            logger.debug("cached - \(fullPathInfo)")
//            return fullPathInfo
//        } else {
//            let newPath = generateFullPath(notebookId: notebookId)
//            if let newPath = newPath {
//                filesPathsCache[notebookId] = newPath
//            }
//            logger.debug("generated - \(newPath ?? "")")
//            return newPath
//        }
//    }
//    
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
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookRenamed(_:)), name: Notification.Name.notebookRenamed, object: nil)
        
        renamedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookInserted).sink { notification in
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
                    
            if isFolder {
                if let info = self.foldersPathInfo[notebookId] {
                    self.foldersPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
                }
            } else {
                if let info = self.filesPathInfo[notebookId] {
                    self.filesPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
                }
            }
            self.invalidateCacheFullPath()
        }
        
    }
    
//    func removeNotebookRenamedObserver() {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookRenamed, object: nil)
//    }
//    
//    @objc func handleNotebookRenamed(_ notification: Notification) async {
//        guard
//            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
//            let name = notification.userInfo?["name"] as? String,
//            let isFolder = notification.userInfo?["isFolder"] as? Bool
//        else { return }
//                
//        if isFolder {
//            if let info = foldersPathInfo[notebookId] {
//                foldersPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
//            }
//        } else {
//            if let info = filesPathInfo[notebookId] {
//                filesPathInfo[notebookId] = LocationInfo(parentId: info.parentId, name: name)
//            }
//        }
//        invalidateCacheFullPath()
//    }
}

// MARK: - Handle Insert
extension NotebooksPathService {
    func observeNotebookInserted() {
        insertedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookInserted).sink { notification in
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
                self.foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
                self.foldersInfoCache.insert(notebookB)
            } else {
                self.filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
                self.filesInfoCache.insert(notebookB)
            }
            self.invalidateCacheFullPath()
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookInserted(_:)), name: Notification.Name.notebookInserted, object: nil)
    }
    
//    func removeNotebookInsertedObserver() {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookInserted, object: nil)
//    }
//    
//    @objc func handleNotebookInserted(_ notification: Notification) async {
//        guard
//            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
//            let name = notification.userInfo?["name"] as? String,
//            let isFolder = notification.userInfo?["isFolder"] as? Bool
//        else { return }
//                
//        let parentId = notification.userInfo?["parent_id"] as? UUID
//        
//        let notebookB = NotebookB(id: notebookId, name: name)
//        notebookB.isFolder = isFolder
//        notebookB.parentId = parentId
//        
//        if isFolder {
//            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
//            foldersInfoCache.insert(notebookB)
//        } else {
//            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
//            filesInfoCache.insert(notebookB)
//        }
//        invalidateCacheFullPath()
//    }
}

// MARK: - Handle move - using insert logic
extension NotebooksPathService {
    func observeNotebookMoved() {
        
        movedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookInserted).sink { notification in
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
                self.foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
                self.foldersInfoCache.remove(notebookB)
                self.foldersInfoCache.insert(notebookB)
            } else {
                self.filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
                self.filesInfoCache.remove(notebookB)
                self.filesInfoCache.insert(notebookB)
            }
            self.invalidateCacheFullPath()
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookMoved(_:)), name: Notification.Name.notebooksMoved, object: nil)
    }

//    func removeNotebookMovedObserver() {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebooksMoved, object: nil)
//    }
    
//    @objc func handleNotebookMoved(_ notification: Notification) async {
//        guard
//            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
//            let name = notification.userInfo?["name"] as? String,
//            let isFolder = notification.userInfo?["isFolder"] as? Bool
//        else { return }
//                
//        let parentId = notification.userInfo?["parent_id"] as? UUID
//        
//        let notebookB = NotebookB(id: notebookId, name: name)
//        notebookB.isFolder = isFolder
//        notebookB.parentId = parentId
//        
//        if isFolder {
//            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
//            foldersInfoCache.remove(notebookB)
//            foldersInfoCache.insert(notebookB)
//        } else {
//            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
//            filesInfoCache.remove(notebookB)
//            filesInfoCache.insert(notebookB)
//        }
//        invalidateCacheFullPath()
//    }
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
        
        cloudSyncFinishObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookInserted).sink { notification in
            
            if let lastRefreshTime = self.lastRefreshTime {
                
                guard let minutes = Calendar.current.dateComponents([.minute], from: lastRefreshTime, to: DateTime.now()).minute else { return }
                if minutes > 1 {
                    self.doRefresh()
                }
                
            } else {
                self.doRefresh()
            }
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
    
    func isDeletedFile(uuid: UUID) -> Bool {
        guard let fileInfo = filesInfoCache.first(where: { $0.id == uuid }) else { return false }
        if fileInfo.isDeleted {
            return true
        } else {
            // check its app parent folders till root
            return isUnderDeletedTreeRecursive(folderId: fileInfo.parentId)
        }
    }
    
    func isUnderDeletedTreeRecursive(folderId: UUID?) -> Bool {
        guard let folderId = folderId else { return false }
        guard let folderInfo = foldersInfoCache.first(where: { $0.id == folderId }) else { return false }
        
        if folderInfo.isDeleted {
            return true
        } else {
            // check its parent
            return isUnderDeletedTreeRecursive(folderId: folderInfo.parentId)
        }
    }
}
