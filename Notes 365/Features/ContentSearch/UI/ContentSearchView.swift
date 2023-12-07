//
//  ContentSearchView.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import SwiftUI

struct ContentSearchView: View {
    
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    @State private var searchText = ""
    let business = BusinessFactory.contentSearchInteractor()
    @State var results = [NotebookContentB]()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(results) { result in
                        Section {
                            SearchDetailView(notebookContentState: $notebookContentState, searchText: searchText, result: result)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                Spacer()
            }
            .searchable(text: $searchText, prompt: "Search Content")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.count >= 3 {
                   results =  business.fetchSearchResults(for: newValue) ?? []
                } else {
                    results.removeAll()
                }
            }
        }
    }
}

struct SearchDetailView: View {
    @Binding var notebookContentState: NotebookContentState
    var searchText: String
    let result: NotebookContentB
    var notebookName: String {
        return NotebooksPathService.shared.fileName(for: result.notebookID) ?? "-"
    }
    var notebookPath: String {
        return NotebooksPathService.shared.fullPath(for: result.notebookID) ?? ""
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: result) {
                VStack(alignment: .leading) {
                    Text(notebookName)
                        .font(.headline)
                    Text(notebookPath)
                        .font(.caption)
                }
            }
        }
        .navigationDestination(for: NotebookContentB.self) { item in
            NotebookContentView(isReadOnly: false, notebookId: item.notebookID, fileName: notebookName, searchText: searchText, notebookContentState: notebookContentState)
        }
    }
}

#Preview {
    ContentSearchView()
}
