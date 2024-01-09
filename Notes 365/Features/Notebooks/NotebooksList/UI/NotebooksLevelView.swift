//
//  NotebooksLevelView.swift
//  Notes 365
//
//  Created by kiran ipc on 22/11/23.
//

import SwiftUI

//struct Item: Identifiable {
//    let id: UUID
//    var name: String
//    var createdDate: Date = DateTime.now()
//}

struct NotebooksBaseDetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            NotebooksLevelView(navigationTitle: "Notebooks", path: $path, parent: nil)
        }
    }
}


struct NotebooksLevelView: View {
    var navigationTitle: String
    @State var currentLevelState = CurrentLevelState()
    @Binding var path: NavigationPath
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    var parent: Notebook?
    
    @State var moveSource: Notebook?
    @State var showMoveView = false
    @State var moveDestination: FileItem?
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                if parent == nil {
                    // base view with search option
                    List {
                        if currentLevelState.isEmpty {
                            emptyView
                        }
                        folderSection
                        fileSection
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .searchable(text: $currentLevelState.searchText, placement: .navigationBarDrawer)
                    .onChange(of: currentLevelState.searchText) { old, new in
                        if new.count > 1 {
                            currentLevelState.searchItems(for: new)
                        } else {
                            currentLevelState.refreshList()
                        }
                    }
                } else {
                    // nested list without search
                    List {
                        if currentLevelState.isEmpty {
                            emptyView
                        }
                        folderSection
                        fileSection
                    }
                }
            }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Notebook.self) { notebook in
            if notebook.isFolder {
                NotebooksLevelView(navigationTitle: notebook.name, path: $path, parent: notebook)
            } else {
                NotebookContentView(isReadOnly: false, notebookId: notebook.id, fileName: notebook.name, notebookContentState: notebookContentState)
                    .onAppear {
                        currentLevelState.notifyNotebookOpen(notebook: notebook)
                        currentLevelState.notifyAddCurrentFolderToRecents()
                    }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        currentLevelState.isCreatingNotebook = true
                        let newItem = currentLevelState.createFolder()
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        currentLevelState.isCreatingNotebook = false
                        if let newItem = newItem {
                            proxy.scrollTo(newItem.id, anchor: .center)
                        }
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
                        let newItem = currentLevelState.createFile()
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        currentLevelState.isCreatingNotebook = false
                        if let newItem = newItem {
                            proxy.scrollTo(newItem.id, anchor: .center)
                        }
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(currentLevelState.isCreatingNotebook)
            }
        })
        .onAppear {
            if currentLevelState.isEmpty {
                currentLevelState.loadItems(for: parent)
            }
        }
        .onChange(of: moveSource, { oldValue, newValue in
            guard let newValue = newValue else { return }
            logger.info("moveSource: \(newValue.name) \(newValue.id)")
            showMoveView = true
        })
        .sheet(isPresented: $showMoveView) {
            MoveToView(notebook: moveSource!, moveDestination: $moveDestination)
        }
        .onChange(of: showMoveView) { old, new in
            if new == false {
                moveSource = nil
                moveDestination = nil
            }
        }
        .onChange(of: moveDestination) { old, new in
            guard let moveSource = moveSource else { return }
            if let destination = new {
                currentLevelState.move(moveSource, to: destination.folderId)
                showMoveView = false
            }
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
                    FolderCellView(currentLevelState: $currentLevelState, moveSource: $moveSource, name: folder.name, notebook: folder)
                }
            }
        }
    }
    
    private var fileSection: some View {
        Section {
            ForEach(currentLevelState.files) { file in
                NavigationLink(value: file) {
                    FileCellView(currentLevelState: $currentLevelState, name: file.name, moveSource: $moveSource, notebook: file)
                }
            }
        }
    }
    
}


struct FolderCellView: View {
    @Environment(\.isSearching) private var isSearching
    @Binding var currentLevelState: CurrentLevelState
    @Binding var moveSource: Notebook?
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
    
    var highlightText: Bool {
        onHover || notebook.isNewlyCreated
    }
    
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
                        .id(notebook.id)
                                .fontWeight(highlightText ? .heavy : .regular)
                                .contextMenu {
                                    RenameButton()
                                    Button {
                                        moveSource = notebook
                                    } label: {
                                        Label("Move", systemImage: "folder")
                                    }
                                    Button(role: .destructive) {
                                        currentLevelState.deleteFolder(notebook: notebook)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .disabled(isSearching)
                                .renameAction {
                                    isEditing = true
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        isEditing = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.yellow)
                                    Button {
                                        moveSource = notebook
                                    } label: {
                                        Label("Move", systemImage: "folder")
                                    }
                                    .tint(.purple)
                                    Button(role: .destructive) {
                                        currentLevelState.deleteFolder(notebook: notebook)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .disabled(isSearching)
                    
                    Spacer()
                    
                    if onHover {
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button {
                                moveSource = notebook
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFolder(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                        .disabled(isSearching)
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
            
            notebook.isNewlyCreated = false
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
    @Environment(\.isSearching) private var isSearching
    @Binding var currentLevelState: CurrentLevelState
    @State var name: String
    @Binding var moveSource: Notebook?
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
    
    var highlightText: Bool {
        onHover || notebook.isNewlyCreated
    }
    
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
                        .id(notebook.id)
                        .fontWeight(highlightText ? .heavy : .regular)
                        .foregroundStyle(Color.primary)
                        .contextMenu {
                            RenameButton()
                            Button {
                                moveSource = notebook
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .disabled(isSearching)
                        .renameAction {
                            isEditing = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.yellow)
                            
                            Button {
                                moveSource = notebook
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            .tint(.purple)
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .disabled(isSearching)
                    
                    Spacer()
                    
                    if onHover {
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button {
                                moveSource = notebook
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            Button(role: .destructive) {
                                currentLevelState.deleteFile(notebook: notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                        .disabled(isSearching)
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
            
            notebook.isNewlyCreated = false
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
