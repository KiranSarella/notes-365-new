//
//  NotebookState.swift
//  Tertiary
//
//  Created by Kiran Sarella on 07/08/21.
//

import Foundation
import CoreData
import SwiftUI


class AppState: ObservableObject {
    
    @Published var selectedSection: UUID?
    
    @Published var appearedSection: UUID?
    
    init() {

    }

    func contentUpdated() {
        objectWillChange.send()
    }
    
}


