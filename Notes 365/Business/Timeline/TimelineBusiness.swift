//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation

class TimelineBusiness {
    
    static let shared = TimelineBusiness()
    
    private init() {
        
    }
    
    func readDayMetaData(dayDate: DayDate) -> String? {
            
        let today = dayDate.date
        let timelinePath = "timeline/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        if FilesHelper.shared.fileExists(atPath: metadataFilePath) == false {
            return nil
        }
        
        return FilesHelper.shared.readBinaryFile(fileName: "metadata", folderPath: timelinePath)!
    }
    
    func readDayMetaData(date: Date) async -> String? {
        
        let timelinePath = "timeline/\(date.getYear())/\(date.getMonth())/\(date.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        if FilesHelper.shared.fileExists(atPath: metadataFilePath) == false {
            return nil
        }
        
        return await FilesHelper.shared.readBinaryFileAsync(fileName: "metadata", folderPath: timelinePath)!
    }
    
//    func dynamicFolderPath(uuid: UUID) -> String? {
//        return DirectoryManager.shared.fullPaths[uuid]
//    }
    
    func readContent(today: Date, fileName: String) async -> String? {
        let folderPath = "timeline/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        return await FilesHelper.shared.readFileAsync(fileName: fileName, folderPath: folderPath)
    }
    
    func timelineExists(day: Date) -> Bool {
        let dayFolderPath = "timeline/\(day.getYear())/\(day.getMonth())/\(day.getDay())"
        return FilesHelper.shared.folderExists(atPath: dayFolderPath)
    }
}
