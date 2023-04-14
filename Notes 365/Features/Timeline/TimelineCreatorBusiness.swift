//
//  TimelineGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/04/23.
//

import Foundation

extension Notification.Name {
    public static let notebookContentUpdated = Notification.Name("com.notes365.notebookContentUpdated")
}

class TimelineCreatorBusiness {
    
    init() {
        registerNotebookChangesNotification()
    }
    
    deinit {
        removeNotebookChangesNotification()
    }
    
    func registerNotebookChangesNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeNotebookChangesNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        guard
            let uuid = notification.userInfo?["id"] as? String,
            let notebookName = notification.userInfo?["notebookName"] as? String,
            let notebookPath = notification.userInfo?["notebookPath"] as? String
        else { return }
        
        Task {
            // get updated content from notebook business
            guard let content = await NotebookContentBusiness.loadContent(id: uuid) else { return }
            // ask todayVersion object to get baseversion
            let baseVersion = TodayVersionBusiness.getBaseVersion(for: uuid) ?? ""
            // do string diff
            // save to timeline path
            let noteChanges = StringDiff.getChanges(old: baseVersion, new: content)
            
            if noteChanges.count == 0 {
                return
            }
            
            let today = Date()
            let timelinePath = "timeline/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
            
            // save noteChanges
            save(noteChanges: noteChanges, to: timelinePath, uuid: uuid)
            // save metadata
            saveMetadata(timelinePath: timelinePath, uuid: uuid, notebookName: notebookName, notebookPath: notebookPath)
        }
        
        
    }
    
    /*
     1. save changes to today's version
     2. remove existing metadata line
     3. prepare metadata line
     4. add new metadata line
     */
//    func addOrUpdateToday(contentChanges: String, uuid: UUID, fileName: String, filePath: String) {
//        let today = Date()
//        let timelinePath = "timeline/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
//
//        // save content
//        saveContent(timelinePath: timelinePath, uuid: uuid, content: contentChanges)
//
//        // save metadata
//        saveMetadata(timelinePath: timelinePath, uuid: uuid, fileName: fileName, filePath: filePath)
//    }
    
    func save(noteChanges: String, to timelinePath: String, uuid: String) {
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        let folderURL = basePathURL.appendingPathComponent(timelinePath)
        let fileURL = folderURL.appendingPathComponent(uuid).appendingPathExtension("md")
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
            try noteChanges.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    func saveMetadata(timelinePath: String, uuid: String, notebookName: String, notebookPath: String) {
        
        let metadataFilePath = timelinePath + "/" + "metadata"
        var metadata: String = ""
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let metaFileURL = basePathURL.appendingPathComponent(metadataFilePath, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: metaFileURL.path) {
            /*
             read metadata file
             form object from it
             update/add this file metadata to this object
             write metadat to file
             
             format:
             UUID Timestamp timezone filename filepath
             */
            
            metadata = readBinaryFile(fileName: "metadata", folderPath: timelinePath) ?? ""
            var lines = metadata.components(separatedBy: "\n")
            // find index
            var searchIndex: Int?
            for i in 0..<lines.count {
                let line = lines[i]
                let words = line.components(separatedBy: "\t")
                if words.first == uuid {
                    searchIndex = i
                    break
                }
            }
            
            if let searchIndex = searchIndex {
                // remove object
                lines.remove(at: searchIndex)
                // clean existing metadata and add each one again
                metadata = ""
                for line in lines {
                    if line.count > 0 {
                        metadata = metadata.appending(line)
                        metadata = metadata.appending("\n")
                    }
                }
            }
        }
        // add this file metadata to this object
        let metadataLine =  "\(uuid)\t\(Date.now)\t\(notebookName)\t\(notebookPath)\n"
        metadata = metadata.appending(metadataLine)
        
        let fileURL = basePathURL.appendingPathComponent(timelinePath).appendingPathComponent("metadata")
        do {
            // Write to the file
            try metadata.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    func readBinaryFile(fileName: String, folderPath: String) -> String? {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return nil }
        
        let fileURL = basePathURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
        
        var readString: String?
        do {
            // Read the file contents
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        return readString
    }
    
}
