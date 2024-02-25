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

    private(set) var folders: Set<NotebookB> = []
    private(set) var files: Set<NotebookB> = []
    
    private(set) var filesLocationDict = [UUID: LocationInfo]()
    private(set) var foldersLocationDict = [UUID: LocationInfo]()

    var foldersGeneratedPath = [UUID: String]()
    var filesGeneratedPath = [UUID: String]()
    
    var cloudSyncFinishedObserver: NSObjectProtocol?
    
    var lastRefreshDate: Date?
    
    var isEmpty: Bool {
        folders.isEmpty && files.isEmpty
    }
    
    var observingServices = false
    
    var renamedObserver: Cancellable?
    var insertedObserver: Cancellable?
    var movedObserver: Cancellable?
    var deletedObserver: Cancellable?
    var cloudSyncFinishObserver: Cancellable?
    
    private init() {
        
    }
    
    
    
    func startObservingServices() {
        if observingServices {
            return
        }
        
        logger.info("\(#function)")
        
        observingServices = true
        
        observeNotebookRenamed()
        observeNotebookInserted()
        observeNotebookMoved()
        observeNotebookDeleted()
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
        
        deletedObserver?.cancel()
        deletedObserver = nil
        
        cloudSyncFinishObserver?.cancel()
        cloudSyncFinishObserver = nil
        
    }
    
    deinit {
//        stopObservingServices()
    }
    
    var refreshTask: Task<(), Never>?
    
    func doRefresh() {
        logger.debug("\(#function)")
        refreshTask?.cancel()   // cancel existing
        refreshTask = Task {
            await refreshNotebooksInfo()
        }
    }
    
    func doRefreshIfNotLoaded() {
        logger.debug("\(#function)")
        if isEmpty {
            doRefresh()
        }
    }
    
    private func refreshNotebooksInfo() async {
        logger.debug("\(#function)")
        if Task.isCancelled { return }
        resetInfoObjects()
        if Task.isCancelled { return }
        updateNotebooksInfo()
        lastRefreshDate = DateTime.now()
        if Task.isCancelled { return }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func resetInfoObjects() {
        folders.removeAll()
        files.removeAll()
        filesLocationDict.removeAll()
        foldersLocationDict.removeAll()
    }
    
    private func updateNotebooksInfo() {
        logger.debug("\(#function)")
        if Task.isCancelled { return }
        let results = notebooksBusiness.getAllFilesInfo()
        if Task.isCancelled { return }
        for result in results {
            if result.isFolder {
                folders.insert(result)
                foldersLocationDict[result.id] = result.locationInfo()
            } else {
                files.insert(result)
                filesLocationDict[result.id] = result.locationInfo()
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
        if let name = filesLocationDict[notebookId]?.name {
            return name
        } else {
//            isLoaded = false
            return nil
        }
    }
    
    func folderFullPath(for notebookId: UUID) async -> String? {
        if let fullPathInfo = foldersGeneratedPath[notebookId] {
            logger.debug("cached - \(fullPathInfo)")
            return fullPathInfo
        } else {
            let newPath = generateFolderFullPath(notebookId: notebookId)
            if let newPath = newPath {
                foldersGeneratedPath[notebookId] = newPath
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
        if let fullPathInfo = filesGeneratedPath[notebookId] {
            logger.debug("cached - \(fullPathInfo)")
            return fullPathInfo
        } else {
            let newPath = generateFullPath(notebookId: notebookId)
            if let newPath = newPath {
                filesGeneratedPath[notebookId] = newPath
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
        if let filePathInfo = self.foldersLocationDict[notebookId] {
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
        if let filePathInfo = self.filesLocationDict[notebookId] {
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
        filesGeneratedPath.removeAll()
        foldersGeneratedPath.removeAll()
    }
    
    private func appendFoldersPath(startingFrom folderId: UUID, in pathComponents: inout [String]) {
        guard let folderPathInfo = foldersLocationDict[folderId] else { return }
        pathComponents.append(folderPathInfo.name)
        if let parentId = folderPathInfo.parentId {
            appendFoldersPath(startingFrom: parentId, in: &pathComponents)
        }
    }
    
}

// MARK: - Handle Rename
extension NotebooksPathService {
    
    func observeNotebookInserted() {
        insertedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookInserted).sink { notification in
            
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
                    
            logger.debug("\(#function)")
            
            let parentId = notification.userInfo?["parent_id"] as? UUID
            
            let notebookB = NotebookB(id: notebookId, name: name)
            notebookB.isFolder = isFolder
            notebookB.parentId = parentId
            
            if isFolder {
                self.folders.remove(notebookB)
                self.folders.insert(notebookB)
                self.foldersLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            } else {
                self.files.remove(notebookB)
                self.files.insert(notebookB)
                self.filesLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            }
            self.invalidateCacheFullPath()
        }
    }
    
    func observeNotebookRenamed() {
        renamedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookRenamed).sink { notification in
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
                    
            logger.debug("\(#function)")
            
            let parentId = notification.userInfo?["parent_id"] as? UUID
            
            let notebookB = NotebookB(id: notebookId, name: name)
            notebookB.isFolder = isFolder
            notebookB.parentId = parentId
            
            if isFolder {
                if let info = self.foldersLocationDict[notebookId] {
                    self.folders.remove(notebookB)
                    self.folders.insert(notebookB)
                    self.foldersLocationDict[notebookId] = LocationInfo(parentId: info.parentId, name: name)
                }
            } else {
                if let info = self.filesLocationDict[notebookId] {
                    self.files.remove(notebookB)
                    self.files.insert(notebookB)
                    self.filesLocationDict[notebookId] = LocationInfo(parentId: info.parentId, name: name)
                }
            }
            self.invalidateCacheFullPath()
        }
    }

    func observeNotebookMoved() {
        movedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebooksMoved).sink { notification in
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
            
            logger.debug("\(#function)")
            
            let parentId = notification.userInfo?["parent_id"] as? UUID
            
            let notebookB = NotebookB(id: notebookId, name: name)
            notebookB.isFolder = isFolder
            notebookB.parentId = parentId
            
            if isFolder {
                self.folders.remove(notebookB)
                self.folders.insert(notebookB)
                self.foldersLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            } else {
                self.files.remove(notebookB)
                self.files.insert(notebookB)
                self.filesLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            }
            self.invalidateCacheFullPath()
        }
    }
    
    func observeNotebookDeleted() {
        deletedObserver = NotificationCenter.default.publisher(for: Notification.Name.notebookDeleted).sink { notification in
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
            
            logger.debug("\(#function)")
            
            let parentId = notification.userInfo?["parent_id"] as? UUID
            
            let notebookB = NotebookB(id: notebookId, name: name)
            notebookB.isFolder = isFolder
            notebookB.parentId = parentId
            notebookB.deletedDate = DateTime.now()
            
            if isFolder {
                self.folders.remove(notebookB)
                self.folders.insert(notebookB)
                self.foldersLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            } else {
                self.files.remove(notebookB)
                self.files.insert(notebookB)
                self.filesLocationDict[notebookId] = LocationInfo(parentId: parentId, name: name)
            }
            self.invalidateCacheFullPath()
        }
    }
    
}


extension NotebookB {
    
    func locationInfo() -> LocationInfo {
        LocationInfo(parentId: parentId, name: name)
    }

}


extension NotebooksPathService {
    
    func observeCloudFinished() {
        logger.debug("\(#function)")
        cloudSyncFinishObserver = NotificationCenter.default
            .publisher(for: Notification.Name.icloudSyncFinished)
            .debounce(for: .seconds(3), scheduler: RunLoop.main)
            .sink { notification in
                if self.lastRefreshDate == nil {
                    self.doRefresh()
                } else if let lastRefreshDate = self.lastRefreshDate {
                    if self.intervalSince(lastRefreshDate, isMoreThan: 3) {
                        self.doRefresh()
                    }
                }
                
        }
    }
    
    func intervalSince(_ previous: Date, isMoreThan minutes: Int) -> Bool {
        return DateTime.now() > previous.advanced(by: Double(minutes) * 60.0)
    }
}


// MARK: - Get all child items
extension NotebooksPathService {
    
    func getAllChildFiles(folderId: UUID) -> [UUID] {
        var recentsFilesToRemove = [UUID]()
        // add child folders and files
        getChildFiles(folderId: folderId, &recentsFilesToRemove)
        
        return recentsFilesToRemove
    }
    
    func getChildFiles(folderId: UUID, _ recentsFilesToRemove: inout [UUID]) {
        // add all child files
        let filesIds = files
            .filter { info in
                info.parentId == folderId && info.isDeleted == false
            }
            .map { $0.id }
        recentsFilesToRemove.append(contentsOf: filesIds)
        // add all child folders
        let subfolderIds = folders
            .filter { info in
                info.parentId == folderId && info.isDeleted == false
            }
            .map { $0.id }
        
        // for each folder again resursively add its childs
        for subfolderId in subfolderIds {
            getChildFiles(folderId: subfolderId, &recentsFilesToRemove)
        }
    }
    
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
        let filesIds = files
                        .filter { info in info.parentId == folderId }
                        .map { $0.id }
        recentsFilesToRemove.append(contentsOf: filesIds)
        
        // add all child folders
        let subfolderIds = folders
                        .filter { info in info.parentId == folderId }
                        .map { $0.id }
        recentsFoldersToRemove.append(contentsOf: subfolderIds)
        
        // for each folder again resursively add its childs
        for subfolderId in subfolderIds {
            getChildFoldersAndFiles(folderId: subfolderId, &recentsFilesToRemove, &recentsFoldersToRemove)
        }
    }
    
    func isDeletedFile(uuid: UUID) -> Bool {
        guard let fileInfo = files.first(where: { $0.id == uuid }) else { return false }
        if fileInfo.isDeleted {
            return true
        } else {
            // check its app parent folders till root
            return isUnderDeletedTreeRecursive(folderId: fileInfo.parentId)
        }
    }
    
    func isUnderDeletedTreeRecursive(folderId: UUID?) -> Bool {
        guard let folderId = folderId else { return false }
        guard let folderInfo = folders.first(where: { $0.id == folderId }) else { return false }
        
        if folderInfo.isDeleted {
            return true
        } else {
            // check its parent
            return isUnderDeletedTreeRecursive(folderId: folderInfo.parentId)
        }
    }
}
