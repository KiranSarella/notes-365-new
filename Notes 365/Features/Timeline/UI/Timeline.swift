//
//  TimelineThree.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation
import Combine
import UIKit

struct Timeline: Identifiable, Hashable {
    var id: String
    var fileUUID: UUID
    var fileName: String
    var filePath: String
    var date: Date
    
    var content: String?
//    var canDisplayContent: Bool = false
    
    var isFirst: Bool = false
    
    mutating func setAsFirst() {
        isFirst = true
    }
    
//    mutating func updateContent(str: String) {
//        self.content = str
//        self.canDisplayContent = true
//    }
}

extension Timeline: Equatable {
    
}
