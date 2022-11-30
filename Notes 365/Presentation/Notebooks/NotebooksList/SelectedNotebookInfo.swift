//
//  UserSelectionState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 11/11/22.
//

import Foundation


struct SelectedNotebookInfo {
    var notebook: NotebookM
    var levels: [Int]
    var index: Int
}

extension SelectedNotebookInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(levels)
        hasher.combine(index)
    }
}
