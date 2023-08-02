//
//  ContentView.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct NotebooksListView: View {

    @Binding var icloudSyncing: Bool
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var selectedNotebook: NotebookM?
    @Environment(\.isSearching) private var isSearching

    @State private var appearDate = Date()
    
    var body: some View {
        
//        Text("Loading..")
//            .opacity(usersState.isLoaded ? 0 : 1)
        VStack {
            if usersState.listSourceType == .notebooks(.none) && usersState.isEmpty {
                AddNotesView()
                    .padding([.top], -100)
                    .environmentObject(usersState)
                    .onAppear {
                        // try again
                        usersState.reloadNotebooksList()
                    }
            } else {
                VStack {
                    //                List(selection: $selectedNotebook) {
                    //                    NotebooksListGroupView(notebooks: $usersState.usersDB.notes)
                    //                }
                    
                    
                    if usersState.listSourceType == .deletedItems ||
                        usersState.listSourceType == .notebooks(.recentlyModified) {
                        
                        SearchedListView(selectedNotebook: $selectedNotebook)
//                            .padding(.bottom, 20)
                            .listStyle(PlainListStyle())
                            .autocorrectionDisabled()
                        
    //                                    .listStyle(SidebarListStyle())
                            .navigationTitle("Notebooks")
                            .navigationBarTitleDisplayMode(.large)
                        
                        if usersState.listSourceType == .deletedItems {
                            Text("Notebooks will be permanently deleted after 30 days.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                            
                    } else {
                        SearchedListView(selectedNotebook: $selectedNotebook)
                            .padding(.bottom, 20)
                            .listStyle(PlainListStyle())
                            .autocorrectionDisabled()
                        
    //                                    .listStyle(SidebarListStyle())
                            .navigationTitle("Notebooks")
                            .navigationBarTitleDisplayMode(.large)
    //                        .onChange(of: selectedNotebook) { newValue in
    //                            if let newValue = newValue {
    //                                usersState.navTitle = newValue.name
    //                            }
    //                        }
                            .searchable(text: $usersState.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    }
                    
                  
                    //                .onChange(of: usersState.searchText) { newValue in
                    //                    selectedNotebook = nil`
                    //                }
                    /*
                     ** IMP
                     
                     .listStyle(SidebarListStyle())
                     
                     this is required to show disclosureGroup when first item have no childs.
                     and only working with SidebarListStyle.
                     

                     */
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        VStack {
                            getToolbarView()
                            Spacer()
                        }
                        .frame(height: 40)
                    }
                }
                .frame(minWidth: 280, maxWidth: 500)
                .confirmationDialog("Are you sure?", isPresented: $usersState.presentDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        guard let temp = usersState.deletingNotebook else { return }
                        usersState.deleteNotebook(ref: temp.notebookRef)
                        usersState.deletingNotebook = nil
                    }
                } message: {
                    Text("You cannot undo this action")
                }
                .onDisappear {
                    usersState.saveExpandedIds()
                }
            }
            
        }
        .onAppear {
            if isSearching {
                return
            }
            usersState.reloadNotebooksList()
            
            if appearDate != Date() {
                usersState.checkOldItemsToDelete()
            }
        }
        .onChange(of: icloudSyncing) { newValue in
            if newValue == true {
                // before sync start
                selectedNotebook = nil
                selectedNotebook = nil
            } else {
                // after sync
                usersState.reloadNotebooksList()
            }
        }
        .onChange(of: usersState.deletingNotebook) { newValue in
            if newValue != nil {
                // if deleting a note, de-select it before deleting
                selectedNotebook = nil
            }
        }
        
    }
    
    var disableActions: Bool {
        
        if selectedNotebook == nil {
            return true
        }
       
        return false
    }
    
    func getToolbarView() -> some View {
        // tool bar
        HStack(alignment: .center, spacing: 20) {
            Group {
                // insert below
                Button(action: {
                    if selectedNotebook == nil {
                        return
                    }
                    usersState.insertBelow(ref: selectedNotebook!.notebookRef)
                }) {
                    //                Image(systemName: "arrow.down")
                    //                    .renderingMode(.original)
                    Text("Add Below")
                }
                // insert inside
                Button(action: {
                    if selectedNotebook == nil {
                        return
                    }
                    usersState.insertInside(ref: selectedNotebook!.notebookRef)
                }) {
                    //                Image(systemName: "arrow.turn.down.right")
                    //                    .renderingMode(.original)
                    Text("Add Inside")
                }
            }
            .buttonStyle(.bordered)
            Spacer()
            // trash
            Button(action: {
                if selectedNotebook == nil {
                    return
                }
                usersState.deletingNotebook = selectedNotebook
//                usersState.presentDeleteConfirmation = true
                guard let temp = usersState.deletingNotebook else { return }
                usersState.deleteNotebookNew(ref: temp.notebookRef)
                usersState.deletingNotebook = nil
                
            }) {
                Image(systemName: "trash")
                    .renderingMode(.original)
            }
        }
        .disabled(disableActions)
        .buttonStyle(PlainButtonStyle())
        .backgroundStyle(.bar)
        .padding()
        
    }
    
}

struct SearchedListView: View {
    
    @Environment(\.editMode) private var editMode
    @Environment(\.isSearching) private var isSearching
    @Binding var selectedNotebook: NotebookM?
    @EnvironmentObject var usersState: NotebooksListState
    
    var body: some View {
        
        switch usersState.listSourceType {
        case .notebooks(let filterType):
            switch filterType {
            case .none:
                EmptyView()
            case .searching:
                if usersState.activeSearch {
                    Text("Search Results: \(usersState.searchResultCount)")
                            .font(.caption)
                            .padding(2)
                }
            case .recentlyModified:
                Text("Recently Modified: \(usersState.modifiedResultCount)")
                        .font(.caption)
                        .padding(2)
            }
        case .deletedItems:
            Text("Deleted Items: \(usersState.deletedResultCount)")
                    .font(.caption)
                    .padding(2)
        }
        
        List(selection: $selectedNotebook) {
            
            if usersState.listSourceType == .deletedItems {
                DeletedNotebooksListGroupView(notebooks: $usersState.notesHierarchy.notes)
            } else {
                NotebooksListGroupView(notebooks: $usersState.notesHierarchy.notes)
            }
            
//            if usersState.notesHierarchy.deletedNotes.count > 0 {
//                Section {
//                    DisclosureGroup {
//                        NotebooksListGroupView(notebooks: $usersState.notesHierarchy.deletedNotes)
//                    } label: {
//                        HStack {
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                            Text("Recently Deleted")
//                                .font(.subheadline)
//                                .fontWeight(.thin)
//                                .foregroundColor(.red)
//                        }
//
//                    }
//                }
//                .tint(.gray)
//            }
            
            
//            Section {
//                DisclosureGroup {
//                    Text("Note 1")
//                } label: {
//                    Text("Recently Deleted")
//                        .fontWeight(.bold)
//                        .foregroundColor(.gray)
//                        .padding(.top, 14)
//                }
//            } header: {
//                Text("Recently Deleted")
//                    .fontWeight(.bold)
//
//            }

            
            
//            DisclosureGroup("recently deleted") {
//                Text("Note 1")
//            }
//            Section("Recently Deleted") {
//                Text("Note 1")
//            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            
            if usersState.canEnableDone {
                // Done button change
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if usersState.listSourceType == .deletedItems {
                            usersState.hideRecentlyDeleted()
                        } else if usersState.listSourceType == .notebooks(.recentlyModified) {
                            usersState.hideRecentlyModified()
                        }
                    }
                }
            } else {
                // menu options
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            usersState.showRecentlyModified()
                        } label: {
                            Text("Recently Modified")
                        }
                        .foregroundColor(.primary)
                        
                        Button {
                            usersState.showRecentlyDeleted()
                        } label: {
                            Text("Deleted Notebooks")
                        }
                        .foregroundColor(.primary)
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }//.disabled(usersState.canEnableDone)
                }
            }
            
            
            
            
            
            
//
//            Button {
//                usersState.showHideRecentlyModified()
//            } label: {
//                Image(systemName: usersState.recentButtonIcon)
//                    .foregroundColor(usersState.listSourceType == .notebooks(.recentlyModified) ? Color.green : Color.accentColor)
//            }
//            .disabled(usersState.listSourceType == ListSourceType.deletedItems ? true : false)
//
//            Button {
//                usersState.showHideRecentlyDeleted()
//            } label: {
//                Image(systemName: usersState.recentlyDeletedButtonIcon)
//                    .foregroundColor(usersState.listSourceType == .deletedItems ? Color.green : Color.accentColor)
//            }
        }
        .onChange(of: isSearching) { newValue in
            // on search active
            if newValue {
                // end editMode
                editMode?.wrappedValue = .inactive
                usersState.listSourceType = .notebooks(.searching)
            }
            
            usersState.isSearching = newValue
//            print("isSearching, ", newValue)
//            selectedNotebook = nil
//            if newValue {
//                usersState.takeBackup()
//            } else {
//                usersState.restoreBackup()
//            }
        }
        .onChange(of: editMode?.wrappedValue) { newValue in
            selectedNotebook = nil
//            if newValue == .active {
//
//            }
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
    @EnvironmentObject var usersState: NotebooksListState
    
    var body: some View {
        VStack(alignment: .center) {
            // show add first notebook button
            Button {
                usersState.addFirstNotes()
            } label: {
                Text(" + Notebook ")
            }.padding()
            Text("add your first notebook")
                .font(Font.subheadline)
            
            
//            VStack {
//                Text("Instead use refresh, if already exits on iCloud")
//                Button {
//                    // get plist on demand
//                    usersState.initialFetch()
//                } label: {
//                    Text("refresh")
//                }
//            }
//            .padding(10)
            

            
//            Text("or")
//                .font(Font.callout)
//
//            Button {
//
//            } label: {
//                Text("Sync from iCloud")
//            }.padding()
        }
    }
}


struct NotebooksListGroupView: View {
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var notebooks: [NotebookM]
    @State private var isTargeted: Bool = true
    var body: some View {
        
        if usersState.listSourceType == .notebooks(.none) ||
            (usersState.listSourceType == .notebooks(.searching) && usersState.activeSearch == false) {
            ForEach($notebooks, id: \.self) { $notebook in
                if notebook.containChildNotebooks {
                    DisclosureGroup(isExpanded: $notebook.isExpanded) {
                        NotebooksListGroupView(notebooks: $notebook.children.unwrap()!)
                    } label: {
                        RowView(notebook: $notebook)
                    }
                } else {
                    RowView(notebook: $notebook)
                }
            }
            .onMove(perform: move) 
        } else {
            ForEach($notebooks, id: \.self) { $notebook in
                if notebook.containChildNotebooks {
                    DisclosureGroup(isExpanded: $notebook.isExpanded) {
                        NotebooksListGroupView(notebooks: $notebook.children.unwrap()!)
    //                                .foregroundColor(notebook.canShow ? .primary : .gray)
    //                                .opacity(notebook.canShow ? 1 : 0.3)
                    } label: {
                        RowView(notebook: $notebook)
    //                                .foregroundColor(notebook.canShow ? .primary : .gray)
                            .opacity(notebook.canShow ? 1 : 0.4)
                    }
                } else {
                    RowView(notebook: $notebook)
    //                            .foregroundColor(notebook.canShow ? .primary : .gray)
                        .opacity(notebook.canShow ? 1 : 0.3)
                }
            }
            .onMove(perform: move)
        }
        
        
//        .onDrop(of: [.text], isTargeted: $isTargeted, perform: { providers in
//            print("ON DROP")
//            return true
//        })
        
        
//        .onInsert(of: [UTType.text]) { pos, prov in
//            print("\n-----> ignoring insert in model1")
//        }
    }
    
    @State private var operationTag = 1
    @State private var draggedItem: NotebookM?
    @State private var isDragging = false
    @State private var isCustomPreview = true
    
    
    private func makeDropDelegate(user: NotebookM) -> DropDelegate {
//        print("makeDropDelegate \(user.name)")
        let operation: DropOperation
        switch operationTag {
        case 1:
            operation = .move
        default:
            operation = .copy
        }
        return CommonDropDelegate(
            currentItem: user,
            operation: operation,
            items: $notebooks,
            draggedItem: $draggedItem,
            onEntered: { _ in
                print("Drop entered - \(user.name)")
                withAnimation { isDragging = true }
            },
            onExit: {
                print("drop exit")
                withAnimation { isDragging = false }
            },
            onPerform: {
                print("drop -onPerform")
                withAnimation { isDragging = false }
            }
        )
    }
    
    private func makeItemProvider(user: NotebookM) -> NSItemProvider {
        print(#function)
        print(user.name)
        isDragging = true
        draggedItem = user
        return NSItemProvider(object: user.id.uuidString as NSItemProviderWriting)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        print(#function, source, destination)
        
//        notebooks.move(fromOffsets: source, toOffset: destination)
//
//        notebooks.first?.notebook.parent?.children?.move(fromOffsets: source, toOffset: destination)
//
        usersState.move(notebooksM: &notebooks, from: source, to: destination)
    }
}



struct RowView: View {
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var notebook: NotebookM
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
//                            store.delete(message)
                            
                            usersState.deletingNotebook = notebook
                            
                            guard let temp = usersState.deletingNotebook else { return }
                            usersState.deleteNotebookNew(ref: notebook.notebookRef)
                            usersState.deletingNotebook = nil
                            
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
//                        Button { store.flag(message) } label: {
//                            Label("Flag", systemImage: "flag")
//                        }
                    }
            }
        }
        .onAppear {
            name = notebook.name
//            isFocused = false
        }
        .contextMenu {
            
            if usersState.listSourceType == .deletedItems {
                Group {
                    // restore
                    Button(action: {
//                        usersState.insertBelow(ref: notebook.notebookRef)
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
                        usersState.deletingNotebook = notebook
    //                    usersState.presentDeleteConfirmation = true
                        
                        usersState.deleteNotebookNew(ref: notebook.notebookRef)
                        usersState.deletingNotebook = nil
                        
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
                        usersState.insertBelow(ref: notebook.notebookRef)
                    }) {
                        Text("Add Below")
                    }
                    // insert inside
                    Button(action: {
                        usersState.insertInside(ref: notebook.notebookRef)
                    }) {
                        Text("Add Inside")
                    }
                    // trash
                    Button(role: .destructive, action: {
                        usersState.deletingNotebook = notebook
    //                    usersState.presentDeleteConfirmation = true
                        
                        
                        usersState.deleteNotebookNew(ref: notebook.notebookRef)
                        usersState.deletingNotebook = nil
                        
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
                try usersState.rename(for: notebook.notebookRef, newValue: name)
//                usersState.navTitle = name
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

// MARK: - Deleted Notebooks

struct DeletedNotebooksListGroupView: View {
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var notebooks: [NotebookM]
    @State private var isTargeted: Bool = true
    var body: some View {
        ForEach($notebooks, id: \.self) { $notebook in
            if notebook.containChildNotebooks {
                DisclosureGroup(isExpanded: $notebook.isExpanded) {
                    DeletedNotebooksListGroupView(notebooks: $notebook.children.unwrap()!)
                } label: {
                    DeletedRowView(notebook: $notebook)
                }
            } else {
                DeletedRowView(notebook: $notebook)
            }
        }
    }
}


struct DeletedRowView: View {
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var notebook: NotebookM
    
    var body: some View {
        HStack {
            Text(notebook.name)
        }
        
        
//        .contextMenu {
//
//            Group {
//                // restore
//                Button(action: {
////                        usersState.insertBelow(ref: notebook.notebookRef)
//                }) {
//                    Label("Restore", image: "arrow.uturn.backward")
////                        HStack {
////                            Text("Restore")
////                            Spacer()
////                            Image(systemName: "arrow.uturn.backward")
////                                .renderingMode(.original)
////                        }
//                }
//
//                // trash
//                Button(role: .destructive, action: {
////                    usersState.deletingNotebook = notebook
//////                    usersState.presentDeleteConfirmation = true
////
////                    usersState.deleteNotebookNew(ref: notebook.notebookRef)
////                    usersState.deletingNotebook = nil
//
//                }) {
//                    HStack {
//                        Text("Delete")
//                        Spacer()
//                        Image(systemName: "trash")
//                            .renderingMode(.original)
//                    }
//                }
//            }
//        }
        
        
        
    }
    
}

