//
//  DateTime.swift
//  Notes 365
//
//  Created by kiran ipc on 28/11/23.
//

import Foundation

class DateTime {
    static let shared = DateTime()
    
    private(set) var date = Date.fromString(dateStr: "05/11/2023")!
    
    #if DEBUG
    static func now() -> Date {
        let onlyDateString = DateTime.shared.date.string(format: "yyyy-MM-dd")
        let onlyTimeString = Date().string(format: "HH:mm:ss")
        let newDateString = "\(onlyDateString) \(onlyTimeString)"
        let format = "yyyy-MM-dd HH:mm:ss"
        
        return newDateString.toLocalDate(withFormat: format)!// ?? DateTime.shared.date
    }
    #else
    static func now() -> Date {
        Date()
    }
    #endif
    
    static func change(now value: Date) {
        DateTime.shared.date = value
    }
    
    static func changeToNextDay() {
        DateTime.shared.date = DateTime.now().dayAfter
        logger.info("\(#function) - \(DateTime.shared.date)")
    }
    
    static func changeToBeforeDay() {
        DateTime.shared.date = DateTime.now().dayBefore
        logger.info("\(#function) - \(DateTime.shared.date)")
    }
    
    // DateTime.now()
    // DateTime.now
}
