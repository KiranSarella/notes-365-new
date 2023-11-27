//
//  DateTime.swift
//  Notes 365
//
//  Created by kiran ipc on 28/11/23.
//

import Foundation

class DateTime {
    static let shared = DateTime()
    
    private(set) var date = Date().dayBefore.dayBefore
    
    static func now() -> Date {
        DateTime.shared.date
    }
    
    // DateTime.now()
    // DateTime.static.now
}
