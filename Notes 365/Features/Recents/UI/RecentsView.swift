//
//  RecentsView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/12/23.
//

import SwiftUI

struct RecentsBaseDetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            RecentsView(navigationTitle: "Recents", path: $path)
        }
    }
}

struct RecentNotebook: Hashable {
    let notebook: Notebook
}

fileprivate struct RecentsView: View {
    var navigationTitle: String
    @State var state = RecentsState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
//    var parent: Notebook?
    
    var body: some View {
        VStack {
            List {
                if state.isEmpty {
                    emptyView
                }
                fileSection
                folderSection
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: RecentNotebook.self) { rn in
            if rn.notebook.isFolder {
                NotebooksLevelView(navigationTitle: rn.notebook.name, path: $path, parent: rn.notebook)
            } else {
                NotebookContentView(isReadOnly: false, notebookId: rn.notebook.id, fileName: rn.notebook.name, notebookContentState: notebookContentState)
            }
        }
        .onAppear {
//            if state.isEmpty {
                state.loadRecents()
//            }
        }
    }
    
    private var emptyView: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack {
                Spacer()
                Text("Empty")
                    .font(.headline)
                Spacer()
            }
            .frame(height: 200)
            Spacer()
        }
        .backgroundStyle(Color.clear)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var folderSection: some View {
        Section {
            ForEach(state.folders) { folder in
                NavigationLink(value: RecentNotebook(notebook: folder)) {
                    SearchFolderCellView(notebook: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(state.files) { file in
                NavigationLink(value: RecentNotebook(notebook: file)) {
                    SearchFileCellView(notebook: file)
                }
            }
        }
    }
    
}


//fileprivate struct RecentFolderCellView: View {
//    let name: String
//    let notebook: Notebook
//    
//    var notebookPath: String {
//        return NotebooksPathService.shared.folderFullPath(for: notebook.id) ?? ""
//    }
//    
//    var body: some View {
//        VStack {
//            Label(notebook.name, systemImage: "folder")
//        }
//    }
//}
//
//
//fileprivate struct RecentFileCellView: View {
//    let name: String
//    let notebook: Notebook
//    
//    var body: some View {
//        VStack {
////            Text("\(notebook.name) \(notebook.modifiedDate.string(format: "mm-dd-yy hh:mm:ss"))")
//            Text(notebook.name)
//                .foregroundStyle(Color.primary)
//        }
//    }
//}
