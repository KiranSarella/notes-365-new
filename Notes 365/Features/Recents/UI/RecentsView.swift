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
            RecentsView(navigationTitle: "Recents", path: $path, parent: nil)
        }
    }
}

struct RecentsView: View {
    var navigationTitle: String
    @State var state = RecentsState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    var parent: Notebook?
    
    var body: some View {
        VStack {
            List {
                if state.isEmpty {
                    emptyView
                }
                folderSection
                fileSection
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Notebook.self) { notebook in
            if notebook.isFolder {
                NotebooksLevelView(navigationTitle: notebook.name, path: $path, parent: notebook)
            } else {
                NotebookContentView(isReadOnly: false, notebookId: notebook.id, fileName: notebook.name, notebookContentState: notebookContentState)
            }
        }
        .onAppear {
            if state.isEmpty {
                state.loadRecents()
            }
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
                NavigationLink(value: folder) {
                    RecentFolderCellView(name: folder.name, notebook: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(state.files) { file in
                Button {
                    path.append(file)
                } label: {
                    RecentFileCellView(name: file.name, notebook: file)
                }
            }
        }
    }
    
}


struct RecentFolderCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
            Label(notebook.name, systemImage: "folder")
        }
    }
}


struct RecentFileCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
            Text(notebook.name)
                .foregroundStyle(Color.primary)
        }
    }
}
