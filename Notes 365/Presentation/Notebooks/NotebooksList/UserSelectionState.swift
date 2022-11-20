//
//  UserSelectionState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import Foundation


struct UserSelectionState {
    var selectedUser: NotebookM
    var selectedLevels: [Int]
    var selectedIndex: Int
    
    //    var folderPath: [String]
}

extension UserSelectionState: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(selectedLevels)
        hasher.combine(selectedIndex)
    }
}
