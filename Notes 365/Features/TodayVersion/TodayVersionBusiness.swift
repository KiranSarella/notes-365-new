//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation

extension Notification.Name {
    public static let notebookContentLoaded = Notification.Name("com.notes365.notebookContentLoaded")
}

class TodayVersionBusiness {
    
    static let baseVersionFolderName = Constants.todayBaseVersionFolderName
    
    static var folderDatePath: String {
        return Date().string(format: "yyyy-MM-dd")
    }
    
    init() {
        registerNotebookLoadedNotification()
    }
    
    deinit {
        removeNotebookLoadedNotification()
    }
    
    func registerNotebookLoadedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookLoadedNotification(_:)), name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    func removeNotebookLoadedNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    @objc func handleNotebookLoadedNotification(_ notification: Notification) {
        // get filename from userInfo
        guard let uuid = notification.userInfo?["id"] as? String else { return }
        Task {
            // ask NotebookBusiness object for content
            let content = await NotebookContentBusiness.loadContent(id: uuid) ?? ""
            // create base version
            TodayVersionBusiness.createBaseVersionIfNotExists(for: uuid, with: content)
        }
    }
    
    static func cleanBaseVersionIfNeeded() {
        // prepare basefolder and todayDate paths
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        let folderURL = basePathURL.appendingPathComponent(baseVersionFolderName, conformingTo: .fileURL)
        let todayPathURL = folderURL.appendingPathComponent(folderDatePath, conformingTo: .fileURL)
        // if new today date folder not exits, then remove all items.
        if FileManager.default.fileExists(atPath: todayPathURL.path(percentEncoded: false)) == false {
            do {
                try FileManager.default.removeAllItems(at: folderURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func createBaseVersionIfNotExists(for fileName: String, with content: String) {
        //        print(#function)
        //        print(fileName, content)
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let folderURL = basePathURL
            .appendingPathComponent(baseVersionFolderName, conformingTo: .fileURL)
            .appendingPathComponent(folderDatePath, conformingTo: .fileURL)
        let fileURL = folderURL.appendingPathComponent(fileName)
            .appendingPathExtension("md")
        print(fileURL)
        // if file already exits, then skip creation steps
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return
        }
        // check if file exists in the server, if so, force download
        
        
        do {
            // create intermediate folders if not exists
            if FileManager.default.fileExists(atPath: folderURL.path) == false {
                do {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            // Write to the file
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    static func isBaseVersionExists(fileName: String) -> Bool {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return false }
        
        let directoryURL = basePathURL
            .appendingPathComponent(fileName, isDirectory: true)
            .appendingPathComponent(folderDatePath, conformingTo: .fileURL)
        let filePath = directoryURL
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    // get base content from todaysVersion/<date>/uuid.md
    static func getBaseVersion(for fileName: String) -> String? {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return nil }
        
        let fileURL = basePathURL
            .appendingPathComponent(baseVersionFolderName)
            .appendingPathComponent(folderDatePath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        
        do {
            // Read the file contents
            return try String(contentsOf: fileURL)
            //            print(fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
}



