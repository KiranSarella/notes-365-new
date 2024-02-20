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

struct DeletedNotebook: Identifiable, Hashable {
    let id: UUID
    let notebook: Notebook
}

fileprivate struct RecentlyDeletedView: View {
    var navigationTitle: String
    @State var state = RecentlyDeletedState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    @State var restoreSource: DeletedNotebook?
    @State var showRestoreView = false
    @State var restoreDestination: FileItem?
    
    let deleteInfoMessage = "Items are available here for 30 days. After that time, items will be permanently deleted."
    
    var body: some View {
        VStack {
            List {
                Section {
                    
                } footer: {
                    HStack {
                        Spacer()
                        Text(deleteInfoMessage)
                            .font(.caption)
                        Spacer()
                    }
                }

                if state.isEmpty {
                    emptyView
                }
                
                fileSection
                folderSection
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: DeletedNotebook.self) { rn in
            if rn.notebook.isFolder {
                DeletedNotebooksLevelView(navigationTitle: rn.notebook.name, path: $path, parent: rn.notebook)
            } else {
                NotebookContentView(isReadOnly: true, notebookId: rn.notebook.id, fileName: rn.notebook.name, state: notebookContentState)
            }
        }
        .onAppear {
            if state.isEmpty {
                state.loadRecentlyDeleted()
            }
        }
        .onChange(of: restoreSource, { oldValue, newValue in
            guard let newValue = newValue else { return }
            logger.info("restoreSource: \(newValue.notebook.name) \(newValue.id)")
            showRestoreView = true
        })
        .onChange(of: restoreDestination) { old, new in
            guard let restoreSource = restoreSource else { return }
            if let destination = new {
                state.restore(restoreSource.notebook, to: destination.folderId)
                showRestoreView = false
            }
        }
        .onChange(of: showRestoreView) { old, new in
            if new == false {
                restoreSource = nil
                restoreDestination = nil
            }
        }
        .sheet(isPresented: $showRestoreView) {
            RestoreToView(notebook: restoreSource!.notebook, moveDestination: $restoreDestination)
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
                    RecentlyDeletedFolderCellView(restoreSource: $restoreSource, name: folder.notebook.name, item: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(state.files) { file in
                NavigationLink(value: file) {
                    RecentlyDeletedFileCellView(restoreSource: $restoreSource, name: file.notebook.name, item: file)
                }
            }
        }
    }
    
}


fileprivate struct RecentlyDeletedFolderCellView: View {
    @Binding var restoreSource: DeletedNotebook?
    let name: String
    let item: DeletedNotebook
    
    @State private var onHover = false
    
    var highlightText: Bool {
        onHover
    }
    
    var body: some View {
        VStack {
            HStack {
                Label(item.notebook.name, systemImage: "folder")
                    .fontWeight(highlightText ? .heavy : .regular)
                    .id(item.id)
                            .contextMenu {
                                Button {
                                    restoreSource = item
                                } label: {
                                    Label("Restore to", systemImage: "folder")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    restoreSource = item
                                } label: {
                                    Label("Restore to", systemImage: "folder")
                                }
                                .tint(.purple)
                            }
                
                Spacer()
                
                if onHover {
                    Menu {
                        Button {
                            restoreSource = item
                        } label: {
                            Label("Restore to", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
    }
}

fileprivate struct RecentlyDeletedFileCellView: View {
    @Binding var restoreSource: DeletedNotebook?
    let name: String
    let item: DeletedNotebook
    
    @State private var onHover = false
    
    var highlightText: Bool {
        onHover
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(item.notebook.name)
                    .foregroundStyle(Color.primary)
                    .fontWeight(highlightText ? .heavy : .regular)
                    .id(item.id)
                            .contextMenu {
                                Button {
                                    restoreSource = item
                                } label: {
                                    Label("Restore to", systemImage: "folder")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    restoreSource = item
                                } label: {
                                    Label("Restore to", systemImage: "folder")
                                }
                                .tint(.purple)
                            }
                
                Spacer()
                
                if onHover {
                    Menu {
                        Button {
                            restoreSource = item
                        } label: {
                            Label("Restore to", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
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
                fileSection
                folderSection
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Notebook.self) { notebook in
            if notebook.isFolder {
                DeletedNotebooksLevelView(navigationTitle: notebook.name, path: $path, parent: notebook)
            } else {
                NotebookContentView(isReadOnly: true, notebookId: notebook.id, fileName: notebook.name, state: notebookContentState)
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
