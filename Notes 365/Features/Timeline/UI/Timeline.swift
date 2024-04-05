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
    var updatedTime: Date
    
    var isDeleted: Bool
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


extension Timeline {
    func timelineB() -> TimelineB {
        var b = TimelineB(notebookId: fileUUID, date: date)
        b.content = content ?? ""
        b.updatedTime = updatedTime
        return b
    }
}
