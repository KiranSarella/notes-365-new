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
    
    var searchResultsTask: Task<(), Never>?
    
    func search(_ newValue: String) {
        searchResultsTask?.cancel()
        searchResultsTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled { return }
            
            if newValue.count >= 3 {
                let resultsData =  business.fetchSearchResults(for: newValue)?.map { $0.viewModel() } ?? []
                
                var newResults = [ContentSearchVM]()
                
                for r in resultsData {
                    
                    if Task.isCancelled { break }
                    
                    let notebookPath = await NotebooksPathService.shared.fileFullPath(for: r.id) ?? ""
                    let notebookName = await NotebooksPathService.shared.fileName(for: r.id) ?? ""
                    let isReadOnly = await NotebooksPathService.shared.isDeletedFile(uuid: r.id)
                    
                    let fullObj = ContentSearchVM(id: r.id, content: r.content, notebookName: notebookName, notebookPath: notebookPath, isReadOnly: isReadOnly)
                    
                    newResults.append(fullObj)
                }
                
                if Task.isCancelled { return }
                results = newResults
                
            } else {
                results.removeAll()
            }
        }
        
        
    }
    
}

