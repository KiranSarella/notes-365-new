//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

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
    
    let timelinePath = Constants.timelineFolderName
    
    init(path basePathURL: URL) {
        self.basePathURL = basePathURL
    }
    
//    private init() {
//
//    }
    
    func readDayMetaData(dayDate: DayDate) -> String? {
            
        let today = dayDate.date
        let timelinePath = "\(timelinePath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
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
        
        let timelinePath = "\(timelinePath)/\(date.getYear())/\(date.getMonth())/\(date.getDay())"
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
        let folderPath = "\(timelinePath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        
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
        let dayFolderPath = "\(timelinePath)/\(day.getYear())/\(day.getMonth())/\(day.getDay())"
        let directoryURL = basePathURL.appendingPathComponent(dayFolderPath)
        return FileManager.default.fileExists(atPath: directoryURL.path)
    }
    
    func removeContent(today: Date, fileName: String) {
        let folderPath = "\(timelinePath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        
        let fileURL = basePathURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
            .appendingPathExtension("md")
        //        print(fileURL.path(percentEncoded: false))
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as NSError {
            print("Failed deleting from URL: \(fileURL), Error: " + error.localizedDescription)
            return nil
        }
    }
}
