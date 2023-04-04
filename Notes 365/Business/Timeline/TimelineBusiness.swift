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
        
        if FilesHelper.shared.fileExists(atPath: metadataFilePath) == false {
            return nil
        }
        
        return FilesHelper.shared.readBinaryFile(fileName: "metadata", folderPath: timelinePath)!
    }
    
    func readDayMetaData(date: Date) async -> String? {
        
        let timelinePath = "\(timelinePath)/\(date.getYear())/\(date.getMonth())/\(date.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        if FilesHelper.shared.fileExists(atPath: metadataFilePath) == false {
            return nil
        }
        
        return await FilesHelper.shared.readBinaryFileAsync(fileName: "metadata", folderPath: timelinePath)!
    }
    
    func readContent(today: Date, fileName: String) async -> String? {
        let folderPath = "\(timelinePath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        return await FilesHelper.shared.readFileAsync(fileName: fileName, folderPath: folderPath)
    }
    
    func timelineExists(day: Date) -> Bool {
        let dayFolderPath = "\(timelinePath)/\(day.getYear())/\(day.getMonth())/\(day.getDay())"
        return FilesHelper.shared.folderExists(atPath: dayFolderPath)
    }
}
