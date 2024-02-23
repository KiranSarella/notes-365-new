//
//  GlobalSharedData.swift
//  Notes 365
//
//  Created by kiran ipc on 23/02/24.
//

import Foundation

class SharedData {
    static let shared = SharedData()
        
    var firstKnowDate: Date = DateTime.now()
    
    
}
