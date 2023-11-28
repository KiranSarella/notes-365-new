//
//  DateTime.swift
//  Notes 365
//
//  Created by kiran ipc on 28/11/23.
//

import Foundation

class DateTime {
    static let shared = DateTime()
    
    private(set) var date = Date().dayBefore.dayBefore.dayBefore
    
    static func now() -> Date {
        DateTime.shared.date
    }
    
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
