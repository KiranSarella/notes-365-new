//
//  TimelineThree.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation
import Combine
import UIKit

struct Timeline: Identifiable {
    var id: String
    var fileUUID: UUID
    var fileName: String
    var filePath: String
    var content: String?
}

extension Timeline: Equatable {
    
}
