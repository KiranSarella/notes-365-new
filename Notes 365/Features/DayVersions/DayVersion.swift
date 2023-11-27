//
//  DayVersion.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation

class DayVersion {
    
    private static let dayVersion = DayVersion()
    
//    static func shared() -> DayVersionInteractor {
//        dayVersion.business
//    }
  
    static let shared: DayVersionInteractor = dayVersion.business
    private let business: DayVersionInteractor = BusinessFactory.dayVersionInteractor()
}
