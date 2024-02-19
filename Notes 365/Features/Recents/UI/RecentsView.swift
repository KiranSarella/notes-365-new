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

struct RecentNotebook: Identifiable, Hashable {
    let id: UUID
    let notebook: Notebook
    var notebookPath: String = ""
}

fileprivate struct RecentsView: View {
    var navigationTitle: String
    @State var state = RecentsState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
//    var parent: Notebook?
//    @State var selection: RecentNotebook?
    
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
            ForEach($state.folders) { $folder in
                NavigationLink(value: folder) {
                    RecentFolderCellView(item: $folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach($state.files) { $file in
                NavigationLink(value: file) {
                    RecentFileCellView(item: $file)
                }
            }
        }
    }
    
}

private struct RecentFolderCellView: View {
    @Binding var item: RecentNotebook
    @FocusState private var isFocused: Bool
    @State private var onHover = false
    
    var highlightText: Bool {
        onHover
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: "folder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32)
                        .fontWeight(highlightText ? .bold : .regular)
                        .foregroundStyle(.tint)
                }
                
                VStack {
                    VStack {
                        HStack {
                            Text(item.notebook.name)
                                .id(item.id)
                                .fontWeight(highlightText ? .heavy : .semibold)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        
                        HStack {
                            Text(item.notebookPath)
                                .font(.caption)
                            Spacer()
                        }
                        
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .task {
            if item.notebookPath.isEmpty {
                item.notebookPath = await NotebooksPathService.shared.folderFullPath(for: item.id) ?? ""
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
    }
}


private struct RecentFileCellView: View {
    @Binding var item: RecentNotebook
    @FocusState private var isFocused: Bool
    @State private var onHover = false
    
    var highlightText: Bool {
        onHover
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(item.notebook.name)
                    .id(item.id)
                    .fontWeight(highlightText ? .heavy : .semibold)
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .padding(.vertical, 2)
            
            HStack {
                Text(item.notebookPath)
                    .font(.caption)
                Spacer()
            }
        }
        .task {
            if item.notebookPath.isEmpty {
                item.notebookPath = await NotebooksPathService.shared.fileFullPath(for: item.id) ?? ""
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
    }
}
