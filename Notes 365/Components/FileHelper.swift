//
//  FileManager.swift
//  TextKit-Scratch-SwiftUI (iOS)
//
//  Created by Kiran Sarella on 22/04/22.
//

import Foundation

// generic filesHelper
// .md file
// .plist file



public class FilesHelper {
    
    
    static let shared = FilesHelper()
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    func isCloudEnabled() -> Bool {
        
        return false
        
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    func getDocumentDiretoryURL() -> URL {
//        print(DocumentsDirectory.localDocumentsURL.path)
        return DocumentsDirectory.localDocumentsURL
        
        if isCloudEnabled()  {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL
        }
    }
    
    // TODO: // apply strategy pattern later
    
    // no extension files
    func writeToBinaryFile(fileName: String, folderPath: String, content: String) {
        
        let DocumentDirURL = getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL.appendingPathComponent(folderPath).appendingPathComponent(fileName)
        
        do {
            // Write to the file
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
   
    
    func readBinaryFileAsync(fileName: String, folderPath: String) async -> String? {
        
        let DocumentDirURL = getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL
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
    
    func readBinaryFile(fileName: String, folderPath: String) -> String? {
        
        let DocumentDirURL = getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL
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
    
    
    // md files
    func writeToFile(fileName: String, folderPath: String, content: String) {
        
        let DocumentDirURL = getDocumentDiretoryURL()
        let folderURL = DocumentDirURL.appendingPathComponent(folderPath)
        let fileURL = folderURL.appendingPathComponent(fileName).appendingPathExtension("md")
        
        do {
            // create intermediate folders if not exists
            if folderExists(atPath: folderPath) == false {
                createDirectory(folderName: folderPath)
            }
            // Write to the file
            try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    func readFile(fileName: String, folderPath: String) -> String? {
        
        let DocumentDirURL = getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        
        var readString: String?
        do {
            // Read the file contents
            readString = try String(contentsOf: fileURL)
            print(fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        return readString
    }
    
    func readFileAsync(fileName: String, folderPath: String) async  -> String? {
//        print(#function, fileName)
        let DocumentDirURL = getDocumentDiretoryURL()
        
        let fileURL = DocumentDirURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        

        do {
            
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
                
            guard let data = try fileHandle.readToEnd() else { return nil }
            
            guard let readString = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            fileHandle.closeFile()
            
            return readString
            
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            
            return nil
        }
    }
    
    func fileExists(atPath path: String) -> Bool {
        
        let documentDirectoryURL = getDocumentDiretoryURL()
        let fileURL = documentDirectoryURL.appendingPathComponent(path, isDirectory: false)
        
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func fileExistsInLocal(atPath path: String) -> Bool {
        
        let documentDirectoryURL = DocumentsDirectory.localDocumentsURL
        let fileURL = documentDirectoryURL.appendingPathComponent(path, isDirectory: false)
        
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    
    
    func renameFile(newFileName: String, oldFileName:String, filePath: String) -> () {
        
        let documentDirURL = getDocumentDiretoryURL()
        
        let fullPath = documentDirURL.appendingPathComponent(filePath)
        
        let newFilePath = fullPath.appendingPathComponent(newFileName).appendingPathExtension("md")
        let oldFilePath = fullPath.appendingPathComponent(oldFileName).appendingPathExtension("md")
        
        // Create a FileManager instance
        let fileManager = FileManager.default
        
        // rename
        do {
            try fileManager.moveItem(atPath: oldFilePath.path, toPath: newFilePath.path)
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    func move(from fromPath: String, to toPath: String) -> () {
        
        let documentDirURL = getDocumentDiretoryURL()
        
        let fullFromPath = documentDirURL.appendingPathComponent(fromPath)
        let fullToPath = documentDirURL.appendingPathComponent(toPath)
        
        // Create a FileManager instance
        let fileManager = FileManager.default
        
        // rename
        do {
            try fileManager.moveItem(atPath: fullFromPath.path, toPath: fullToPath.path)
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    func renameFolder(new newFolderName: String, old oldFolderName:String, folderPath: String) -> () {
        
        let documentDirURL = getDocumentDiretoryURL()
        
        let fullPath = documentDirURL.appendingPathComponent(folderPath)
        
        let newFolderPath = fullPath.appendingPathComponent(newFolderName)
        let oldFolderPath = fullPath.appendingPathComponent(oldFolderName)
        
        // Create a FileManager instance
        let fileManager = FileManager.default
        
        // rename
        do {
            try fileManager.moveItem(atPath: oldFolderPath.path, toPath: newFolderPath.path)
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    // directory
    func createDirectory(folderName: String) {
        
        let documentDirectoryURL = getDocumentDiretoryURL()
        let directoryURL = documentDirectoryURL.appendingPathComponent(folderName, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            print("folder already exists ", directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    // delete
    
    func deleteFile(fileName: String? = nil, path: String) {
     
        let documentDirectoryURL = getDocumentDiretoryURL()
        let dirURL = documentDirectoryURL.appendingPathComponent(path, isDirectory: true)
        
        var fileURL = dirURL
        
        if let fileName = fileName {
            fileURL = dirURL.appendingPathComponent(fileName)
        }
        fileURL = fileURL.appendingPathExtension("md")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteFolder(path: String) {
        let documentDirectoryURL = getDocumentDiretoryURL()
        let directoryURL = documentDirectoryURL.appendingPathComponent(path, isDirectory: true)
        
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}


extension FilesHelper {
    
    func folderExists(atPath folderPath: String) -> Bool {
        
        let documentDirectoryURL = getDocumentDiretoryURL()
        let directoryURL = documentDirectoryURL.appendingPathComponent(folderPath)  //appendingPathComponent(folderPath, isDirectory: true)
        
//        print(directoryURL.path, FileManager.default.fileExists(atPath: directoryURL.path))
        
        return FileManager.default.fileExists(atPath: directoryURL.path)
    }
    
    
    func fileExists(atPath filePath: String, fileName: String) -> Bool {
        
        let documentDirectoryURL = getDocumentDiretoryURL()
        let directoryURL = documentDirectoryURL.appendingPathComponent(filePath, isDirectory: true)
        let filePath = directoryURL.appendingPathComponent(fileName).appendingPathExtension("md")
        
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
}
