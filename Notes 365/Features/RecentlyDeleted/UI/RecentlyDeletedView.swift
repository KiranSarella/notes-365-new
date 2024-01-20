//
//  RecentlyDeletedView.swift
//  Notes 365
//
//  Created by kiran ipc on 19/01/24.
//

import SwiftUI

struct RecentlyDeletedBaseDetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            RecentlyDeletedView(navigationTitle: "Recently Deleted", path: $path)
        }
    }
}

struct DeletedNotebook: Hashable {
    let notebook: Notebook
}

fileprivate struct RecentlyDeletedView: View {
    var navigationTitle: String
    @State var state = RecentlyDeletedState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
//    var parent: Notebook?
    
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
        .navigationDestination(for: RecentNotebook.self) { rn in
            if rn.notebook.isFolder {
                NotebooksLevelView(navigationTitle: rn.notebook.name, path: $path, parent: rn.notebook)
            } else {
                NotebookContentView(isReadOnly: false, notebookId: rn.notebook.id, fileName: rn.notebook.name, notebookContentState: notebookContentState)
            }
        }
        .onAppear {
//            if state.isEmpty {
                state.loadRecentlyDeleted()
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
                    RecentlyDeletedFolderCellView(name: folder.name, notebook: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(state.files) { file in
                NavigationLink(value: RecentNotebook(notebook: file)) {
                    RecentlyDeletedFileCellView(name: file.name, notebook: file)
                }
//                Button {
//                    path.append(file)
//                } label: {
//                    RecentFileCellView(name: file.name, notebook: file)
//                }
            }
        }
    }
    
}


fileprivate struct RecentlyDeletedFolderCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
//            Label("\(notebook.name) \(notebook.modifiedDate.string(format: "mm-dd-yy hh:mm:ss"))", systemImage: "folder")
            Label(notebook.name, systemImage: "folder")
        }
    }
}


fileprivate struct RecentlyDeletedFileCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
//            Text("\(notebook.name) \(notebook.modifiedDate.string(format: "mm-dd-yy hh:mm:ss"))")
            Text(notebook.name)
                .foregroundStyle(Color.primary)
        }
    }
}
