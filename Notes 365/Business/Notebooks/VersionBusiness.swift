//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation

class VersionBusiness {
    static let shared = VersionBusiness()
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
        FilesHelper.shared.writeToFile(fileName: uuid.uuidString, folderPath: timelinePath, content: contentChanges)
        // save metadata
        let metadataFilePath = timelinePath + "/" + "metadata"
        var metadata: String = ""
        if FilesHelper.shared.fileExists(atPath: metadataFilePath) {
            /*
             read metadata file
             form object from it
             update/add this file metadata to this object
             write metadat to file
             
             format:
             UUID Timestamp timezone filename filepath
             */
            metadata = FilesHelper.shared.readBinaryFile(fileName: "metadata", folderPath: timelinePath)!
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
        
        FilesHelper.shared.writeToBinaryFile(fileName: "metadata", folderPath: timelinePath, content: metadata)
    }
    
    
    
    static func cleanOldBaseVersions() {
        
        let today = Date()
        
        if let oldBaseVersionDate = UserDefaults.standard.object(forKey: "base-version-date") as? Date {
            if oldBaseVersionDate.isSameDayAs(today) == false {
                reset()
            }
        } else {
            reset()
        }
        
        
        func reset() {
            // remove all files in `today_base_version`
            FilesHelper.shared.deleteFolder(path: "today_base_version")
            
            FilesHelper.shared.createDirectory(folderName: "today_base_version")
            
            UserDefaults.standard.setValue(today, forKey: "base-version-date")
        }
    }
 
    
    static func getImagePath(forImage imageName: String) -> String {
        
        let documentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileNameWithExtension = imageName
        let indexFileUrl = documentDirUrl.appendingPathComponent(fileNameWithExtension)
        
        return indexFileUrl.path
    }

}



