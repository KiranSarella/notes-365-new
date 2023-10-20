//
//  ContentView.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine
import SwiftData


public enum NotebookListOption: String, CaseIterable, Identifiable {
    case all
    case modified
    case deleted
    case bookmarks
    case tags
    
    public var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .all:
            return "all"
        case .modified:
            return "modified"
        case .deleted:
            return "deleted"
        case .bookmarks:
            return "bookmarks"
        case .tags:
            return "tags"
        }
    }
}


struct NotebooksListView: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var notebooksListState: NotebooksListState
//    @Binding var selectedNotebook: Notebook.ID?
    @Binding var selectedNotebook: Notebook?
    @Environment(\.isSearching) private var isSearching

    @State private var firstTimeAppear = true
    @State private var appearDate = Date()
    
    @State private var calenderType: NotebookListOption = .all
    
//    @State private var colors: [UUID] = []
    @State private var colors: [Notebook] = []
    @State private var editorState = NotebookEditorState()
    
    @Environment(\.scenePhase) var scenePhase
    
    func sortedNotes(notebooks: inout [Notebook]) {
        for i in 0..<notebooks.count {
            notebooks[i].sortChildren()
        }
    }
    
    var body: some View {

        VStack {
            if notebooksListState.isLoading {
                ProgressView()
            } else if notebooksListState.listSourceType == .notebooks(.none) && notebooksListState.isEmpty {
                AddNotesView(notebooksListState: notebooksListState)
                    .padding([.top], -100)
            } else {
                VStack {
                    
                    if notebooksListState.listSourceType == .deletedItems ||
                        notebooksListState.listSourceType == .notebooks(.recentlyModified) {
                        
                        NavigationStack(path: $colors) {
                            
                            SearchedListView(selectedNotebook: $selectedNotebook, notebooksListState: notebooksListState)
    //                            .padding(.bottom, 20)
                                .autocorrectionDisabled()
                                .navigationTitle("Notebooks")
                                .navigationBarTitleDisplayMode(.large)
                                .onChange(of: selectedNotebook, { oldValue, newValue in
                                    if let newValue = newValue {
                                        // ** do navigation to editor
                                        editorState.setupNewNotebook(&selectedNotebook!)
                                        colors.append(newValue)
                                        
                                        print(selectedNotebook?.name, selectedNotebook?.id)
                                        print(newValue.name, newValue.id)
                                    }
                                })
                            
                            if notebooksListState.listSourceType == .deletedItems {
                                Text("Notebooks will be permanently deleted after 30 days.")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .navigationDestination(for: Notebook.self) { color in
                            NotebookEditorView(listDisplayState: notebooksListState.listSourceType, editorState: editorState)
                        }
                        
                            
                    } else {
                        NavigationStack(path: $colors) {
                         
                            SearchedListView(selectedNotebook: $selectedNotebook, notebooksListState: notebooksListState)
                            .padding(.bottom, 20)
                            .autocorrectionDisabled()
                            .navigationTitle("Notebooks")
                            .navigationBarTitleDisplayMode(.large)
                            .onChange(of: selectedNotebook, { oldValue, newValue in
                                if let newValue = newValue {
                                    // ** do navigation to editor
                                    editorState.setupNewNotebook(&selectedNotebook!)
                                    colors.append(newValue)
                                    
                                    print(selectedNotebook?.name, selectedNotebook?.id)
                                    print(newValue.name, newValue.id)
                                }
                            })
                            .searchable(text: $notebooksListState.searchText, placement: .navigationBarDrawer(displayMode: .always))
                            .onChange(of: notebooksListState.searchText) { oldValue, newValue in
                                notebooksListState.searchTextPublisher.send(newValue)
                            }
                        }
                        .navigationDestination(for: Notebook.self) { color in
                            NotebookEditorView(listDisplayState: notebooksListState.listSourceType, editorState: editorState)
                        }
                    }
                }
                .onDisappear {
                    notebooksListState.saveExpandedIds()
                }
            }
            
        }
        .onAppear {
            
            selectedNotebook = nil
            editorState.modelContext = modelContext
            notebooksListState.modelContext = modelContext
            
            notebooksListState.notebookBusiness.modelContext = modelContext
            
            if notebooksListState.notebooks.count == 0 {
                notebooksListState.fetchNotebooks()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { (_) in
              print("UIApplication: willEnterForegroundNotification")
            notebooksListState.fetchNotebooks()
        }
//        onChange(of: scenePhase, { oldPhase, newPhase in
//            if newPhase == .active {
//                print("Active")
////                usersState.fetchNotebooks()
//            } else if newPhase == .inactive {
//                print("Inactive")
//            } else if newPhase == .background {
//                print("Background")
//            }
//        })
        
    }
    
    var disableActions: Bool {
        
        if selectedNotebook == nil {
            return true
        }
       
        return false
    }
}

struct SearchedListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    @Environment(\.isSearching) private var isSearching
//    @Binding var selectedNotebook: Notebook.ID?
    @Binding var selectedNotebook: Notebook?
    @Bindable var notebooksListState: NotebooksListState
    
    @Namespace var topID
    @Namespace var bottomID
    
    var body: some View {
        
        switch notebooksListState.listSourceType {
        case .notebooks(let filterType):
            switch filterType {
            case .none:
                EmptyView()
            case .searching:
                if notebooksListState.activeSearch {
                    Text("Search Results: \(notebooksListState.searchResultCount)")
                            .font(.caption)
                            .padding(2)
                }
            case .recentlyModified:
                Text("Recently Modified: \(notebooksListState.modifiedResultCount)")
                        .font(.caption)
                        .padding(2)
            }
        case .deletedItems:
            Text("Deleted Items: \(notebooksListState.deletedResultCount)")
                    .font(.caption)
                    .padding(2)
        }
        
        List(selection: $selectedNotebook) {
            if notebooksListState.listSourceType == .deletedItems {
                NotebooksListGroupView(notebooksListState: notebooksListState, notebooks: $notebooksListState.deletedNotebooks)
            } else {
                NotebooksListGroupView(notebooksListState: notebooksListState, notebooks: $notebooksListState.notebooks)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            if notebooksListState.canEnableDone {
                // Done button change
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if notebooksListState.listSourceType == .deletedItems {
                            notebooksListState.hideRecentlyDeleted()
                        } else if notebooksListState.listSourceType == .notebooks(.recentlyModified) {
                            notebooksListState.hideRecentlyModified()
                        }
                    }
                }
            } else {
                // menu options
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            notebooksListState.showRecentlyModified()
                        } label: {
                            Text("Recently Modified")
                        }
                        .foregroundColor(.primary)
                        
                        Button {
                            notebooksListState.showRecentlyDeleted()
                        } label: {
                            Text("Deleted Notebooks")
                        }
                        .foregroundColor(.primary)
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onChange(of: isSearching) { newValue in
            // on search active
            if newValue {
                // end editMode
                editMode?.wrappedValue = .inactive
                notebooksListState.listSourceType = .notebooks(.searching)
            }
            
            notebooksListState.isSearching = newValue
        }
        .onChange(of: editMode?.wrappedValue) { newValue in
            selectedNotebook = nil
        }
    }
    
}

struct MyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                    Spacer()
                    Text(configuration.isExpanded ? "hide" : "show")
                        .foregroundColor(.accentColor)
                        .font(.caption.lowercaseSmallCaps())
                        .animation(nil, value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

struct AddNotesView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var notebooksListState: NotebooksListState
    
    var body: some View {
        VStack(alignment: .center) {
            // show add first notebook button
            Button {
                notebooksListState.addFirstNotes()
            } label: {
                Text(" + Notebook ")
            }.padding()
            Text("add your first notebook")
                .font(Font.subheadline)
        }
    }
}


struct NotebooksListGroupView: View {
    @Bindable var notebooksListState: NotebooksListState
    @Binding var notebooks: [Notebook]
    var body: some View {
        
        if notebooksListState.listSourceType == .notebooks(.none) ||
            (notebooksListState.listSourceType == .notebooks(.searching) && notebooksListState.activeSearch == false) {
            ForEach($notebooks, id: \.self) { $notebook in
                MyTableRow(notebooksListState: notebooksListState, notebook: $notebook)
            }
        } else {
            ForEach($notebooks, id: \.self) { $notebook in
                MyTableDeletedRow(notebooksListState: notebooksListState, notebook: $notebook)
            }
        }
    }
}

struct MyTableRow: View {
    
    @Bindable var notebooksListState: NotebooksListState
    @Binding var notebook: Notebook
    
    var body: some View {
        
        // normal
        if notebook.containChildNotebooks {
            DisclosureGroup(isExpanded: $notebook.isExpanded) {
                NotebooksListGroupView(notebooksListState: notebooksListState, notebooks: $notebook.children.unwrap()!)
            } label: {
                RowView(notebooksListState: notebooksListState, notebook: $notebook)
                    .id(notebook.id)
            }
        } else {
            RowView(notebooksListState: notebooksListState, notebook: $notebook)
                .id(notebook.id)
        }
    }
}

struct MyTableDeletedRow: View {
    
    @Bindable var notebooksListState: NotebooksListState
    @Binding var notebook: Notebook
    
    var body: some View {
        if notebook.containChildNotebooks {
            DisclosureGroup(isExpanded: $notebook.isExpanded) {
                NotebooksListGroupView(notebooksListState: notebooksListState, notebooks: $notebook.children.unwrap()!)
            } label: {
                DeletedRowView(notebooksListState: notebooksListState, notebook: $notebook)
                    .opacity(notebook.canShow ? 1 : 0.4)
            }
        } else {
            DeletedRowView(notebooksListState: notebooksListState, notebook: $notebook)
                .opacity(notebook.canShow ? 1 : 0.4)
        }
    }
}

struct RowView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var notebooksListState: NotebooksListState
    @Binding var notebook: Notebook
    @State private var name: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var showFileExistsAlert = false
    @State private var showInvalidCharsAlert = false
    
    @State private var isEditing = false {
        didSet {
            isFocused = isEditing
        }
    }
    
    var disableActions: Bool {
        return false
    }
    
    var body: some View {
        HStack {
            if isEditing {
                TextField(text: $name) {
                    Text("Notebook")
                }
                .background(Color.gray)
                .focused($isFocused)
            } else {
                Text(notebook.name)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                notebooksListState.delete(notebook: notebook)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .onAppear {
            name = notebook.name
//            isFocused = false
        }
        .contextMenu {
            
            if notebooksListState.listSourceType == .deletedItems {
                Group {
                    // restore
                    Button(action: {
//                        usersState.insertBelow(ref: notebook)
                    }) {
                        Label("Restore", image: "arrow.uturn.backward")
//                        HStack {
//                            Text("Restore")
//                            Spacer()
//                            Image(systemName: "arrow.uturn.backward")
//                                .renderingMode(.original)
//                        }
                    }
                    
                    // trash
                    Button(role: .destructive, action: {
                        Task {
                            notebooksListState.delete(notebook: notebook)
                        }
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .renderingMode(.original)
                        }
                    }
                }
                .disabled(disableActions)
            } else {
                Group {
                    RenameButton()
                    // insert below
                    Button(action: {
                        notebooksListState.insertBelow(ref: notebook)
                    }) {
                        Text("Add Below")
                    }
                    // insert inside
                    Button(action: {
                        notebooksListState.insertInside(ref: notebook)
                    }) {
                        Text("Add Inside")
                    }
                    // trash
                    Button(role: .destructive, action: {
                        Task {
                            notebooksListState.delete(notebook: notebook)
                        }
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .renderingMode(.original)
                        }
                    }
                }
                .disabled(disableActions)
            }
            
            
        }
        .renameAction {
            isEditing = true
        }
        .onChange(of: isEditing, perform: { newValue in
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
                try notebooksListState.rename(for: notebook, newValue: name)
                isEditing = false
            } catch NotebookBusinessError.alreadyExists {
                showFileExistsAlert = true
                isEditing = true
            } catch NotebookBusinessError.invalidCharacters {
                showInvalidCharsAlert = true
                isEditing = true
            } catch {
//                name = notebook.name
            }
        }
        .confirmationDialog("Failed to rename file", isPresented: $showFileExistsAlert) {
            
        } message: {
            Text("filename already exists")
        }
        .confirmationDialog("Failed to rename file", isPresented: $showInvalidCharsAlert) {
            
        } message: {
            Text("filename contains unsupported characters")
        }
    }
    
}


struct DeletedRowView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var notebooksListState: NotebooksListState
    @Binding var notebook: Notebook
    @State private var name: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var showFileExistsAlert = false
    @State private var showInvalidCharsAlert = false
    
    @State private var isEditing = false {
        didSet {
            isFocused = isEditing
        }
    }
    
    var disableActions: Bool {
        return false
    }
    
    var body: some View {
        HStack {
            if isEditing {
                TextField(text: $name) {
                    Text("Notebook")
                }
                .background(Color.gray)
                .focused($isFocused)
            } else {
                Text(notebook.name)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                notebooksListState.delete(notebook: notebook)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .onAppear {
            name = notebook.name
//            isFocused = false
        }
        .contextMenu {
            
            if notebooksListState.listSourceType == .deletedItems {
                Group {
                    // restore
                    Button(action: {
//                        usersState.insertBelow(ref: notebook)
                    }) {
                        Label("Restore", image: "arrow.uturn.backward")
//                        HStack {
//                            Text("Restore")
//                            Spacer()
//                            Image(systemName: "arrow.uturn.backward")
//                                .renderingMode(.original)
//                        }
                    }
                    
                    // trash
                    Button(role: .destructive, action: {
                        Task {
                            notebooksListState.delete(notebook: notebook)
                        }
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .renderingMode(.original)
                        }
                    }
                }
                .disabled(disableActions)
            } else {
                Group {
                    RenameButton()
                    // insert below
                    Button(action: {
                        notebooksListState.insertBelow(ref: notebook)
                    }) {
                        Text("Add Below")
                    }
                    // insert inside
                    Button(action: {
                        notebooksListState.insertInside(ref: notebook)
                    }) {
                        Text("Add Inside")
                    }
                    // trash
                    Button(role: .destructive, action: {
                        Task {
                            notebooksListState.delete(notebook: notebook)
                        }
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .renderingMode(.original)
                        }
                    }
                }
                .disabled(disableActions)
            }
            
            
        }
        .renameAction {
            isEditing = true
        }
        .onChange(of: isEditing, perform: { newValue in
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
                try notebooksListState.rename(for: notebook, newValue: name)
                isEditing = false
            } catch NotebookBusinessError.alreadyExists {
                showFileExistsAlert = true
                isEditing = true
            } catch NotebookBusinessError.invalidCharacters {
                showInvalidCharsAlert = true
                isEditing = true
            } catch {
//                name = notebook.name
            }
        }
        .confirmationDialog("Failed to rename file", isPresented: $showFileExistsAlert) {
            
        } message: {
            Text("filename already exists")
        }
        .confirmationDialog("Failed to rename file", isPresented: $showInvalidCharsAlert) {
            
        } message: {
            Text("filename contains unsupported characters")
        }
    }
    
}
