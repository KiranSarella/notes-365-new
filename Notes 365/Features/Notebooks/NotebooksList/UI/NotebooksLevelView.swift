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
    var createdDate: Date = DateTime.now()
}

struct NotebooksBaseDetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            NotebooksLevelView(navigationTitle: "Notebooks", path: $path, parent: nil)
        }
    }
}


struct NotebooksLevelView: View {
    
    var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 120)), count: 10)
    }
    
    var columns = [GridItem(.adaptive(minimum: 200))]
    
    var navigationTitle: String
    
    @State var currentLevelState = CurrentLevelState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    var parent: Notebook?
    
    var body: some View {
        VStack {
            if currentLevelState.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Empty")
                            .font(.headline)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                List {
                    Section {
                        ForEach(currentLevelState.folders) { folder in
                            NavigationLink(value: folder) {
                                FolderCellView(currentLevelState: $currentLevelState, name: folder.name, notebook: folder)
                            }
                        }
                    }
                    Section {
                        ForEach(currentLevelState.files) { file in
                            Button {
                                path.append(file)
                            } label: {
                                FileCellView(currentLevelState: $currentLevelState, name: file.name, notebook: file)
                            }
                        }
                    }
                }
                
            }
        }
        .navigationTitle(navigationTitle)
        .navigationDestination(for: Notebook.self) { notebook in
            if notebook.isFolder {
                NotebooksLevelView(navigationTitle: notebook.name, path: $path, parent: notebook)
            } else {
                NotebookContentView(isReadOnly: false, notebookId: notebook.id, fileName: notebook.name, notebookContentState: notebookContentState)
            }
        }
        .toolbar(content: {
            toolbarItems()
        })
        .onAppear {
            if currentLevelState.isEmpty {
                currentLevelState.loadItems(for: parent)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() ->  some ToolbarContent {
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
    @Binding var currentLevelState: CurrentLevelState
    @State var name: String
    var notebook: Notebook
    @FocusState private var isFocused: Bool
    @State private var isEditing = false {
        didSet {
            isFocused = isEditing
        }
    }
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var onHover = false
    
    var body: some View {
        VStack {
            if isEditing {
                TextField(text: $name) {
                    Text("Notebook")
                }
                .background(Color.gray)
                .focused($isFocused)
            } else {
                HStack {
                    Label(notebook.name, systemImage: "folder")
                                .contextMenu {
                                    RenameButton()
                                    Button(role: .destructive) {
                                        currentLevelState.deleteFolder(notebook: notebook)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .renameAction {
                                    isEditing = true
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        isEditing = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        currentLevelState.deleteFolder(notebook: notebook)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                    
                    Spacer()
                    
                    if onHover {
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFolder(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                }
                
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
        .onChange(of: isEditing, { oldValue, newValue in
            if newValue == false {
                // on escape, reset content
                name = notebook.name
            }
        })
        .onSubmit {
            if name == notebook.name {
                isEditing = false
                return
            }
            do {
                try currentLevelState.rename(for: notebook, newValue: name)
                isEditing = false
            } catch NotebookBusinessError.alreadyExists {
                errorMessage = "filename already exists"
                showAlert = true
                isEditing = true
            } catch NotebookBusinessError.invalidCharacters {
                errorMessage = "filename contains unsupported characters"
                showAlert = true
                isEditing = true
            } catch {
//                name = notebook.name
            }
        }
        .confirmationDialog("rename failed", isPresented: $showAlert) {
            
        } message: {
            Text(errorMessage)
        }
    }
}


struct FileCellView: View {
    @Binding var currentLevelState: CurrentLevelState
    @State var name: String
    var notebook: Notebook
    @FocusState private var isFocused: Bool
    @State private var isEditing = false {
        didSet {
            isFocused = isEditing
        }
    }
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var onHover = false
    
    var body: some View {
        VStack {
            if isEditing {
                TextField(text: $name) {
                    Text("Notebook")
                }
                .background(Color.gray)
                .focused($isFocused)
            } else {
                HStack {
                    Text(notebook.name)
                        .foregroundStyle(Color.primary)
                        .contextMenu {
                            RenameButton()
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .renameAction {
                            isEditing = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    
                    Spacer()
                    
                    if onHover {
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .onHover { newValue in
            onHover = newValue
        }
#endif
        .onChange(of: isEditing, { oldValue, newValue in
            if newValue == false {
                // on escape, reset content
                name = notebook.name
            }
        })
        .onSubmit {
            if name == notebook.name {
                isEditing = false
                return
            }
            do {
                try currentLevelState.rename(for: notebook, newValue: name)
                isEditing = false
            } catch NotebookBusinessError.alreadyExists {
                errorMessage = "filename already exists"
                showAlert = true
                isEditing = true
            } catch NotebookBusinessError.invalidCharacters {
                errorMessage = "filename contains unsupported characters"
                showAlert = true
                isEditing = true
            } catch {
//                name = notebook.name
            }
        }
        .confirmationDialog("rename failed", isPresented: $showAlert) {
            
        } message: {
            Text(errorMessage)
        }
    }
}
