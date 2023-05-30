//
//  RecentList.swift
//  Notes 365
//
//  Created by kiran ipc on 29/05/23.
//

import Foundation
import Collections

extension Notification.Name {
    public static let notebookEdited = Notification.Name("com.notes365.notebookEdited")
}

class RecentNotebooksList {
    
    var basePathURL: URL
    private var capacity: Int = 10
    private var deque: Deque<String> = []
    
    var items: Set<String> {
        Set(deque)
    }
    
    var itemsList: [String] {
        Array(deque)
    }
    
    init(_ basePathURL: URL) {
        self.basePathURL = basePathURL
        registerNotebookChangesNotification()
        
        populateData()
    }
    
    deinit {
        removeNotebookChangesNotification()
    }
    
    func populateData() {
        if let items = retrieveItems() {
            deque.append(contentsOf: items)
        }
    }
    
    func add(_ id: String) {
        deque.append(id)
        if deque.count > capacity {
            deque.removeFirst()
        }
    }
    
    func remove(_ id: String) {
        if let i = deque.firstIndex(of: id) {
            deque.remove(at: i)
            persist(items: itemsList)
        }
    }
    
    func registerNotebookChangesNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeNotebookChangesNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        guard
            let uuid = notification.userInfo?["id"] as? String
        else { return }
        
        add(uuid)
        persist(items: itemsList)
    }
    
    // It will save only notebooks list hierarchy to plist, not notebook content.
    func persist(items: [String]) {
        
        do {
            // generate data
            let plistData = try PropertyListEncoder().encode(items)
            // prepare path
            let fileURL = basePathURL.appendingPathComponent(Constants.recentPListName).appendingPathExtension("plist")
            // save file
            do {
                // Write to the file
                try plistData.write(to: fileURL)
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        } catch {
            print("Save Failed")
        }
    }
    
    // retrives notebooks hierarcy from plist, not the notebook content.
    func retrieveItems() -> [String]? {
        
        let plistURL = basePathURL.appending(path: Constants.recentPListName).appendingPathExtension("plist")
        
        do {
            // Read the file contents
            let plistData = try Data(contentsOf: plistURL)
            let recentList = try PropertyListDecoder().decode([String].self, from: plistData)
            return recentList
        } catch let error as NSError {
            print("Failed reading from URL: \(plistURL), Error: " + error.localizedDescription)
        }
        return nil
    }
}
