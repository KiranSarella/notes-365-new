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
                DeletedNotebooksLevelView(navigationTitle: rn.notebook.name, path: $path, parent: rn.notebook)
            } else {
                NotebookContentView(isReadOnly: true, notebookId: rn.notebook.id, fileName: rn.notebook.name, notebookContentState: notebookContentState)
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
            }
        }
    }
    
}


fileprivate struct RecentlyDeletedFolderCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
            Label(notebook.name, systemImage: "folder")
        }
    }
}


fileprivate struct RecentlyDeletedFileCellView: View {
    let name: String
    let notebook: Notebook
    
    var body: some View {
        VStack {
            Text(notebook.name)
                .foregroundStyle(Color.primary)
        }
    }
}


struct DeletedNotebooksLevelView: View {
    var navigationTitle: String
    @State var currentLevelState = CurrentLevelState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    var parent: Notebook?
    
    @State var moveSource: Notebook?
    @State var showMoveView = false
    @State var moveDestination: FileItem?
    @State var showPurchaseView = false
    
    var body: some View {
        VStack {
            // nested list without search
            List {
                if currentLevelState.isEmpty {
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
                DeletedNotebooksLevelView(navigationTitle: notebook.name, path: $path, parent: notebook)
            } else {
                NotebookContentView(isReadOnly: true, notebookId: notebook.id, fileName: notebook.name, notebookContentState: notebookContentState)
                    .onAppear {
                        currentLevelState.notifyNotebookOpen(notebook: notebook)
                        currentLevelState.notifyAddCurrentFolderToRecents()
                    }
            }
        }
        .onAppear {
            if currentLevelState.isEmpty {
                currentLevelState.loadItems(for: parent)
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
            ForEach(currentLevelState.folders) { folder in
                NavigationLink(value: folder) {
                    DeletedFolderCellView(notebook: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(currentLevelState.files) { file in
                NavigationLink(value: file) {
                    DeletedFileCellView(notebook: file)
                }
            }
        }
    }
    
    
}


struct DeletedFolderCellView: View {
    var notebook: Notebook
    
    var body: some View {
        VStack {
            HStack {
                Label(notebook.name, systemImage: "folder")
                    .id(notebook.id)
                Spacer()
            }
            .padding(.vertical, 2)
        }
    }
}


struct DeletedFileCellView: View {
    var notebook: Notebook
   
    var body: some View {
        VStack {
            HStack {
                Text(notebook.name)
                    .id(notebook.id)
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .padding(.vertical, 2)
        }
    }
}
