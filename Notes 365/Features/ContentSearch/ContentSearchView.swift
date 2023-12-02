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
//                HStack {
//                    Spacer()
//                    TextField("Search", text: $searchText)
//                        .frame(width: 200, height: 60)
//                        .padding()
//                        .textFieldStyle(.roundedBorder)
//                    Spacer()
//                        
//                }
                List {
                    ForEach(results) { result in
                        Section {
                            SearchDetailView(notebookContentState: $notebookContentState, result: result)
                        }
                    }
    //                SearchDetailView()
    //                SearchDetailView()
    //                SearchDetailView()
                }
                Spacer()
            }
            .searchable(text: $searchText)
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
    let result: NotebookContentB
    var notebookName: String {
        return NotebooksPathService.shared.fileName(for: result.notebookID) ?? "-"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(notebookName)
                    .font(.headline)
                Spacer()
            }
            HStack {
                NavigationLink(value: result) {
                    Text(result.content)
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
        .navigationDestination(for: NotebookContentB.self) { item in
            NotebookContentView(isReadOnly: false, notebookId: item.notebookID, fileName: notebookName, notebookContentState: notebookContentState)
        }
//        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
    }
}

#Preview {
    ContentSearchView()
}
