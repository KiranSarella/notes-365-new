//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation

class VersionBusiness {
    
    static let shared = VersionBusiness()
    
    static let baseVersionFolderName = Constants.todayBaseVersionFolderName
    
    private init() {}
    
    /*
     1. save changes to today's version
     2. remove existing metadata line
     3. prepare metadata line
     4. add new metadata line
     */
    func addOrUpdateToday(contentChanges: String, uuid: UUID, fileName: String, filePath: String) {
        let today = Date()
        let timelinePath = "timeline/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        
        // save content
        saveContent(timelinePath: timelinePath, uuid: uuid, content: contentChanges)
        
        // save metadata
        saveMetadata(timelinePath: timelinePath, uuid: uuid, fileName: fileName, filePath: filePath)
    }
    
    func saveContent(timelinePath: String, uuid: UUID, content: String) {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let folderURL = basePathURL.appendingPathComponent(timelinePath)
        let fileURL = folderURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("md")
        
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
    
    func saveMetadata(timelinePath: String, uuid: UUID, fileName: String, filePath: String) {
        
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
                if words.first == uuid.uuidString {
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
        let metadataLine =  "\(uuid.uuidString)\t\(Date.now)\t\(fileName)\t\(filePath)\n"
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
    
    
    /*
     
     */
    static func resetBaseVersionIfNeeded() {
        
        // TODO: Instead of saving base-version-date in user defaults, use date for the folder
        // ex: base_version_20-07-2022
        // clean up - except base_version_20-07-2022, remove all base_version_* folders
        
        let today = Date.now
        if let oldBaseVersionDate = UserDefaults.standard.object(forKey: "base-version-date") as? Date {
            if oldBaseVersionDate.isSameDayAs(today) == false {
                // reset if day changed
                reset()
            }
        } else {
            // reset - means create new base version
            reset()
        }
        
        func reset() {
            
            guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
            
            // remove all files in `today_base_version`
            
            let directoryURL = basePathURL.appendingPathComponent("today_base_version", isDirectory: true)
            
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch {
                print(error.localizedDescription)
            }
            
            
            // recreate new directory
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
            
            // save todays date
            UserDefaults.standard.setValue(today, forKey: "base-version-date")
        }
    }
 
    
    static func getImagePath(forImage imageName: String) -> String {
        
        let documentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileNameWithExtension = imageName
        let indexFileUrl = documentDirUrl.appendingPathComponent(fileNameWithExtension)
        
        return indexFileUrl.path
    }

    
    // MARK: - base version
    static func createBaseVersion(for fileName: String, with content: String) {
        //        print(#function)
        //        print(fileName, content)
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let folderURL = basePathURL.appendingPathComponent(baseVersionFolderName)
        let fileURL = folderURL.appendingPathComponent(fileName).appendingPathExtension("md")
        
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
        
        let directoryURL = basePathURL.appendingPathComponent(fileName, isDirectory: true)
        let filePath = directoryURL.appendingPathComponent(fileName).appendingPathExtension("md")
        
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    static func getBaseVersion(for fileName: String) -> String? {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return nil }
        
        let fileURL = basePathURL
            .appendingPathComponent(baseVersionFolderName)
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



