//
//  NotebooksLevelView.swift
//  Notes 365
//
//  Created by kiran ipc on 22/11/23.
//

import SwiftUI

struct Item: Identifiable {
    let id: UUID
    var name: String
    var createdDate: Date = Date()
}

struct NotebookDetailBaseView: View {
    
    @Binding var notebooksState: NotebooksListState
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            NotebooksLevelView(path: $path, notebook: notebooksState.root)
        }
        
//        NavigationStack(path: $path) {
//            NotebooksLevelView(path: $path, notebook: <#Notebook#>)
//        }
//        .onDisappear {
//            path = NavigationPath()
//        }
    }
}

struct NotebooksLevelView: View {
    
    var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 120)), count: 10)
    }
    
    var columns = [GridItem(.adaptive(minimum: 200))]
    
    @State var navigationTitle: String = ""
    
    @State var currentLevelState = CurrentLevelState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    var notebook: Notebook
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
//                List {
                VStack {
                    LazyVGrid(columns: columns, alignment: .leading) {
                        ForEach(currentLevelState.folders) { folder in
                            NavigationLink(value: folder) {
                                FolderCellView(folder: folder)
                            }
                        }
                    }
                }
                VStack {
                    ForEach(currentLevelState.files) { file in
                        NavigationLink(value: file) {
                            FileCellView(file: file)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationDestination(for: Notebook.self) { notebook in
                if notebook.isFolder {
                    NotebooksLevelView(path: $path, notebook: notebook)
                } else {
                    NotebookContentView(isReadOnly: false, notebookId: notebook.id, editorState: notebookContentState)
                }
                
            }
        }
        .toolbar(content: {
            toolbarItems()
        })
        .onAppear {
            navigationTitle = notebook.name
            if currentLevelState.isEmpty {
                currentLevelState.loadItems(for: notebook)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() ->  some ToolbarContent {
            // menu options
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
//                        notebooksListState.showRecentlyModified()
                    } label: {
                        Text("Recently Modified")
                    }
                    .foregroundColor(.primary)
                    Button {
//                        notebooksListState.showRecentlyDeleted()
                    } label: {
                        Text("Deleted Notebooks")
                    }
                    .foregroundColor(.primary)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
               
                Button {
                    Task {
                        currentLevelState.isCreatingNotebook = true
                        currentLevelState.createFolder()
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        currentLevelState.isCreatingNotebook = false
                    }
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .disabled(currentLevelState.isCreatingNotebook)
            }
            
        ToolbarItem(placement: .topBarTrailing) {
               
                Button {
                    Task {
                        currentLevelState.isCreatingNotebook = true
                        currentLevelState.createFile()
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        currentLevelState.isCreatingNotebook = false
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(currentLevelState.isCreatingNotebook)
            }
          
        
        
            
    }

    
}
//
//#Preview {
//    NotebooksLevelView()
//}

struct FolderSection: View {
    
    let items:[Item]
    
    var body: some View {
        Text("asdf")
    }
}

struct Fruit: Identifiable {
    let id: UUID = UUID()
    let name: String
    let color: Color
}

extension Fruit: Hashable {
    
}

struct FolderCellView: View {
    let folder: Notebook
    var body: some View {
        HStack {
            Image(systemName: "folder")
                .font(.system(size: 40))
                .fontWeight(.light)
            Text(folder.name)
                .font(.body)
                .foregroundStyle(Color.primary)
                .padding()
        }
        .padding()
    }
}

struct FileCellView: View {
    let file: Notebook

    var body: some View {
        HStack {
            Text(file.name)
                .font(.body)
                .foregroundStyle(Color.primary)
            Spacer()
        }
        .padding()
    }
}


