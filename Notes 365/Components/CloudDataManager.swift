//
//  CloudSyncManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/05/22.
//

import Foundation


/*
 
 
 on fresh app, check if icloud enabled
 if
 - create everything in icloud drive itself
 - it will auto sync to other devices
 - user will reload the notebook to see latest content (if both are live? how to update.. then mostly have to use notifications/cloudkit)
 else
 - do everything in local
 
 sync:
 if icloud is enabled
 - sync local to icloud (only do if local is latest, otherwise use icloud storage and ignore local -- if both are modified -- have to merge - manually check each and every file date .. or give user to sync manually)
 - delete local (delayed)
 if icloud is disabled
 - sync icloud to local
 - don't touch icloud (icloud might be enabled in other devices)
 
 */



class CloudDataManager {
    
    static let shared = CloudDataManager() // Singleton
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    
    // Return the Document directory (Cloud OR Local)
    // To do in a background thread
    
    func getDocumentDiretoryURL() -> URL {
        
        return DocumentsDirectory.localDocumentsURL
        
//        if isCloudEnabled()  {
//            return DocumentsDirectory.iCloudDocumentsURL!
//        } else {
//            return DocumentsDirectory.localDocumentsURL
//        }
    }
    
    // Return true if iCloud is enabled
    
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    // Delete All files at URL
    
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                print("remove item: ", url!.appendingPathComponent(file))
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }
    
    // Copy local files to iCloud
    // iCloud will be cleared before any operation
    // No data merging
    
    func saveFileTest() {
        
        let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        guard let fileURL = driveURL?.appendingPathComponent("\(UUID().uuidString).txt") else { return }
        
        

        do {
            print(fileURL)
            try "Hello word".data(using: .utf8)?.write(to: fileURL)
            
            print("Copied to iCloud")
        } catch let error as NSError {
            print("Failed to move file to Cloud : \(error)")
        }
        
    }
    
    func copyFileToCloud(folderPath: String) {
        if isCloudEnabled() {
            
            deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
            
            let fileManager = FileManager.default
            
            let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fullPath = documentDirURL.appendingPathComponent(folderPath)
            
            let cloudPath = DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(folderPath)
            
            do {
                print(fullPath, cloudPath)
                try fileManager.copyItem(at: fullPath, to: cloudPath)
                
                print("Copied to iCloud")
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
    }
    
    func copyFileToCloud() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                    
                    print("Copied to iCloud")
                } catch let error as NSError {
                    print("Failed to move file to Cloud : \(error)")
                }
            }
        }
    }
    
    // Copy iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    
    func copyFileToLocal() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
                    
                    print("Moved to local dir")
                } catch let error as NSError {
                    print("Failed to move file to local dir : \(error)")
                }
            }
        }
    }
    
    
    
    
    
}
