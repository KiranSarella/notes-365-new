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
//    var fullPathsCache = [UUID: FullPathInfo]()
    var pathsCache = [UUID: String]()
    private(set) var isLoaded = false
    var cloudSyncFinishedObserver: NSObjectProtocol?
    
    
    private init() {
        observeNotebookRenamed()
        observeNotebookInserted()
        observeNotebookMoved()
        observeCloudFinished()
    }
    
    func refreshOnNextService() {
        isLoaded = false
    }
    
    func refreshNotebooksInfo() async {
        if isLoaded {
            return
        }
        await updateNotebooksInfo()
        isLoaded = true
    }
    
    private func updateNotebooksInfo() async {
        return await withCheckedContinuation { c in
            let results = notebooksBusiness.getAllFilesInfo()
            for result in results {
                if result.isFolder {
                    foldersPathInfo[result.id] = result.locationInfo()
                } else {
                    filesPathInfo[result.id] = result.locationInfo()
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
    
    func fullPath(for notebookId: UUID) -> String? {
        if let fullPathInfo = pathsCache[notebookId] {
            logger.debug("cached - \(fullPathInfo)")
            return fullPathInfo
        } else {
            let newPath = generateFullPath(notebookId: notebookId)
            if let newPath = newPath {
                pathsCache[notebookId] = newPath
            }
            logger.debug("generated - \(newPath ?? "")")
            return newPath
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
    
    
//    func path(for notebookId: UUID) async -> FullPathInfo? {
//        if let fullPathInfo = fullPathsCache[notebookId] {
//            return fullPathInfo
//        } else {
//            let newPath = await generatePath(notebookId: notebookId)
//            if let newPath = newPath {
//                pathsCache[notebookId] = "uhi > kuhku"//newPath
//            }
//            return newPath
//        }
//    }

//    func generatePath(notebookId: UUID) async -> FullPathInfo? {
//        return await withCheckedContinuation { continution in
//            if let filePathInfo = self.filesPathInfo[notebookId] {
//                
//                var pathComponents = [String]()
//                pathComponents.append(filePathInfo.name)
//                if let folderId = filePathInfo.parentId {
//                    appendFoldersPath(startingFrom: folderId, in: &pathComponents)
//                }
//                let fullPath = pathComponents.reversed().joined(separator: "  \u{203A}   ")
//                let fullPathInfo = FullPathInfo(id: notebookId, name: filePathInfo.name, fullPath: fullPath)
////                fullPathsCache[notebookId] = fullPathInfo
//    //                defer {
//    //                    fullPathsCache[notebookId] = fullPathInfo
//    //                }
//                continution.resume(returning: fullPathInfo)
//    //                return fullPathInfo
//            } else {
//                continution.resume(returning: nil)
//            }
//        }
//    }
    
    private func invalidateCacheFullPath() {
//        fullPathsCache.removeAll()
        pathsCache.removeAll()
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
        
        if isFolder {
            foldersPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
        } else {
            filesPathInfo[notebookId] = LocationInfo(parentId: parentId, name: name)
        }
        invalidateCacheFullPath()
    }
}

// MARK: - Handle move - using insert logic
extension NotebooksPathService {
    func observeNotebookMoved() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookInserted(_:)), name: Notification.Name.notebookInserted, object: nil)
    }
    
    func removeNotebookMovedObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebooksMoved, object: nil)
    }
}

extension NotebooksPathService {
    func observeAppStateChanged() {
//        NotificationCenter.default.addObserver(self, selector: "asdf", name: UIApplication.willEnterForegroundNotification, object: nil)
    }
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
