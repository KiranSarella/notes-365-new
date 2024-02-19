//
//  ContentSearchState.swift
//  Notes 365
//
//  Created by kiran ipc on 19/02/24.
//

import SwiftUI

struct ContentSearchVM: Identifiable, Hashable {
    var id: UUID
    var content: String = ""
    var notebookName: String = ""
    var notebookPath: String = ""
    var isReadOnly: Bool = false
}

extension NotebookContentB {
    func viewModel() -> ContentSearchVM {
        ContentSearchVM(id: notebookID, content: content)
    }
}

@Observable
class ContentSearchState {
    
    var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    var searchText = ""
    let business = BusinessFactory.contentSearchInteractor()
    var results = [ContentSearchVM]()
    
    init() {
        
    }
    
    func search(_ newValue: String) {
        if newValue.count >= 3 {
            results =  business.fetchSearchResults(for: newValue)?.map { $0.viewModel() } ?? []
        } else {
            results.removeAll()
        }
    }
    
}

