//
//  RecentsDataService.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import Foundation

class RecentsDataService {
    static let shared = RecentsDataService()
    var filesOpenObserver: NSObjectProtocol?
    let notebooksBusiness = BusinessFactory.recentsInteractor()
    
    private init() {
        
    }
    
    func startProviding() {
        observeFilesOpen()
        observeNotebookRenamed()
    }
    
    func stopProviding() {
        filesOpenObserver = nil
        removeNotebookRenamedObserver()
    }
    
    private func observeFilesOpen() {
        filesOpenObserver = NotificationCenter.default.addObserver(forName: .addToRecent, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            
            guard
                let notebookId = notification.userInfo?["notebook_id"] as? UUID,
                let name = notification.userInfo?["name"] as? String,
                let isFolder = notification.userInfo?["isFolder"] as? Bool
            else { return }
                    
            let recentItem = RecentItem(id: notebookId, name: name, isFolder: isFolder, updatedDate: DateTime.now())
            
            do {
                try notebooksBusiness.addRecent(item: recentItem)
            } catch {
                logger.error("\(error)")
            }
        }
    }
    
}

// MARK: - Handle Rename
extension RecentsDataService {
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
                
        do {
            try notebooksBusiness.rename(id: notebookId, name: name)
        } catch {
            logger.error("\(error)")
        }
    }
}
