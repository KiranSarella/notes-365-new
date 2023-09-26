//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftData

class TimelineBusiness {
    
//    static let shared = TimelineBusiness()
    
//    private static var _instance: TimelineBusiness!
//
//    static func shared(basePath: URL) -> TimelineBusiness {
//        if _instance == nil {
//            _instance = TimelineBusiness(basePathURL: basePath)
//        }
//        return _instance
//    }
    
    var basePathURL: URL
    
    let timelineFolderPath = Constants.timelineFolderName
    
    var modelContext: ModelContext?
    
    init(path basePathURL: URL) {
        self.basePathURL = basePathURL
    }
    
//    private init() {
//
//    }
    
    func readDayMetaData(dayDate: DayDate) -> String? {
            
        let today = dayDate.date
        let timelinePath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        let fileURL = basePathURL.appendingPathComponent(metadataFilePath, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: fileURL.path) == false {
            return nil
        }

        do {
            // Read the file contents
            return try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
    
    func readDayMetaData(date: Date) async -> String? {
        
        let timelinePath = "\(timelineFolderPath)/\(date.getYear())/\(date.getMonth())/\(date.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        let fileURL = basePathURL.appendingPathComponent(metadataFilePath, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: fileURL.path) == false {
            return nil
        }

        do {
            // Read the file contents
            return try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
    
    func readContent(today: Date, fileName: String) async -> String? {
        let folderPath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        
        let fileURL = basePathURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        //        print(fileURL.path(percentEncoded: false))
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            guard
                let data = try fileHandle.readToEnd(),
                let readString = String(data: data, encoding: .utf8) else { return nil }
            
            fileHandle.closeFile()
            return readString
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
    
    func timelineExists(day: Date) -> Bool {
        let dayFolderPath = "\(timelineFolderPath)/\(day.getYear())/\(day.getMonth())/\(day.getDay())"
        let directoryURL = basePathURL.appendingPathComponent(dayFolderPath)
        return FileManager.default.fileExists(atPath: directoryURL.path)
    }
    
    // MARK: - Remove Timeline
    func removeTimelineChanges(_ timeline: Timeline) {
        // remove timeline file
        removeContent(today: Date(), fileName: timeline.fileUUID.uuidString)
        // remove row from metadata file
        removeFromMetadata(uuid: timeline.fileUUID.uuidString)
        // remove base version
        TodayVersionBusiness.removeBaseVersion(for: timeline.fileUUID, modelContext: modelContext!)
    }
    
    func removeContent(today: Date, fileName: String) {
        let folderPath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        
        let fileURL = basePathURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        //        print(fileURL.path(percentEncoded: false))
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as NSError {
            print("Failed deleting from URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    func removeFromMetadata(uuid: String, today: Date = Date()) {
        
        let timelinePath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        var metadata: String = ""
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let metaFileURL = basePathURL.appendingPathComponent(timelinePath, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: metaFileURL.path) {
            /*
             read metadata file
             form object from it
             remove this file metadata to this object
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
        
        let fileURL = basePathURL.appendingPathComponent(timelinePath).appendingPathComponent("metadata")
        do {
            // Write to the file
            try metadata.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
}

// MARK: - Timeline Creation
extension Notification.Name {
    public static let notebookContentUpdated = Notification.Name("com.notes365.notebookContentUpdated")
}

extension TimelineBusiness {
    
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
            let baseVersion = TodayVersionBusiness.getBaseVersion(for: UUID(uuidString: uuid)!, modelContext: modelContext!) ?? ""
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
