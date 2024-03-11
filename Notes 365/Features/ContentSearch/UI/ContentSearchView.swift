//
//  ContentSearchView.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import SwiftUI


struct ContentSearchView: View {
    
    @State var state = ContentSearchState()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(state.results) { result in
                        Section {
                            SearchDetailView(result: result)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                Spacer()
            }
            .ignoresSafeArea(edges: [.bottom])
            .searchable(text: $state.searchText, placement: .navigationBarDrawer, prompt: "Search Content")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ContentSearchVM.self) { item in
                NotebookContentView(isReadOnly: item.isReadOnly, notebookId: item.id, fileName: item.notebookName, searchText: state.searchText, state: state.notebookContentState)
            }
            .onChange(of: state.searchText) { oldValue, newValue in
                state.search(newValue)
            }
        }
        
    }
}

struct SearchDetailView: View {
    let result: ContentSearchVM
    
    var body: some View {
        VStack {
            NavigationLink(value: result) {
                 VStack(alignment: .leading) {
                     Text(result.notebookName)
                        .font(.headline)
                     Text(result.notebookPath)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    ContentSearchView()
}
