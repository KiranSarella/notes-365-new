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
    @Bindable var usersState: NotebooksListState
    @Binding var selectedNotebook: Notebook.ID?
    @Environment(\.isSearching) private var isSearching
    //    @State private var presentDeleteConfirmation = false
    //    @State private var deletingNotebook: NotebookM?
    @State private var selectNotebook: Notebook?
    var body: some View {
        
        //        Text("Loading..")
        //            .opacity(usersState.isLoaded ? 0 : 1)
        VStack {
            if usersState.isSearching == false && usersState.isEmpty {
                AddNotesView(usersState: usersState)
                    .padding([.top], -100)
                    .onAppear {
                        // try again
                        usersState.reloadNotebooksList()
                    }
            } else {
                VStack {
                    //                List(selection: $selectedNotebook) {
                    //                    NotebooksListGroupView(notebooks: $usersState.usersDB.notes)
                    //                }
                    
                    List(usersState.notebooks, children: \.children, selection: $selectedNotebook) { notebook in
                        
                        VStack {
                            Text(notebook.name)
                                .contextMenu {
                                    Group {
                                        RenameButton()
                                        // insert below
                                        Button(action: {
                                            usersState.insertBelow(ref: notebook)
                                        }) {
                                            Text("Add Below")
                                        }
                                        // insert inside
                                        Button(action: {
                                            usersState.insertInside(ref: notebook)
                                        }) {
                                            Text("Add Inside")
                                        }
                                        // trash
                                        Button(role: .destructive, action: {
                                            //                                usersState.deletingNotebook = notebook
                                            //            //                    usersState.presentDeleteConfirmation = true
                                            //
                                            //
                                            //                                usersState.deleteNotebookNew(ref: notebook)
                                            //                                usersState.deletingNotebook = nil
                                            
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
                        
                        
                    }
                    
                    .onChange(of: selectNotebook, { oldValue, newValue in
                        print(oldValue, newValue)
                    })
                    
                    //                    SearchedListView(selectedNotebook: $selectedNotebook, usersState: usersState)
                    //                        .padding(.bottom, 20)
                    //                        .listStyle(PlainListStyle())
                    //                        .autocorrectionDisabled()
                    //
                    ////                                    .listStyle(SidebarListStyle())
                    //                        .navigationTitle("Notebooks")
                    ////                        .onChange(of: selectedNotebook) { newValue in
                    ////                            if let newValue = newValue {
                    ////                                usersState.navTitle = newValue.name
                    ////                            }
                    ////                        }
                    //                        .searchable(text: $usersState.searchText)
                    //                    //                .onChange(of: usersState.searchText) { newValue in
                    //                    //                    selectedNotebook = nil
                    //                    //                }
                    //                    /*
                    //                     ** IMP
                    
                    .listStyle(SidebarListStyle())
                    
                    ////                     this is required to show disclosureGroup when first item have no childs.
                    ////                     and only working with SidebarListStyle.
                    ////
                    //                     DisclosureGroup(isExpanded: .constant(true)) {
                    //                     ListGroupView(notebooks: $usersState.usersDB.notes)
                    //                     } label: {
                    //
                    //                     }.disabled(true)
                    //                     */
                    //
                    //                    if UIDevice.current.userInterfaceIdiom == .pad {
                    //                        VStack {
                    ////                            getToolbarView()
                    //                            Spacer()
                    //                        }
                    //                        .frame(height: 40)
                    //                    }
                }
                .frame(minWidth: 280, maxWidth: 500)
                .confirmationDialog("Are you sure?", isPresented: $usersState.presentDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        guard let temp = usersState.deletingNotebook else { return }
                        usersState.deleteNotebook(ref: temp)
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
        }
        .onChange(of: icloudSyncing, { oldValue, newValue in
            if newValue == true {
                // before sync start
                selectedNotebook = nil
                selectedNotebook = nil
            } else {
                // after sync
                usersState.reloadNotebooksList()
            }
        })
        .onChange(of: usersState.deletingNotebook, { oldValue, newValue in
            if newValue != nil {
                // if deleting a note, de-select it before deleting
                selectedNotebook = nil
            }
        })
        
    }
    
    var disableActions: Bool {
        
        if selectedNotebook == nil {
            return true
        }
        
        return false
    }
    
    //    func getToolbarView() -> some View {
    //        // tool bar
    //        HStack(alignment: .center, spacing: 20) {
    //            Group {
    //                // insert below
    //                Button(action: {
    //                    if selectedNotebook == nil {
    //                        return
    //                    }
    //                    usersState.insertBelow(ref: selectedNotebook!)
    //                }) {
    //                    //                Image(systemName: "arrow.down")
    //                    //                    .renderingMode(.original)
    //                    Text("Add Below")
    //                }
    //                // insert inside
    //                Button(action: {
    //                    if selectedNotebook == nil {
    //                        return
    //                    }
    //                    usersState.insertInside(ref: selectedNotebook)
    //                }) {
    //                    //                Image(systemName: "arrow.turn.down.right")
    //                    //                    .renderingMode(.original)
    //                    Text("Add Inside")
    //                }
    //            }
    //            .buttonStyle(.bordered)
    //            Spacer()
    //            // trash
    //            Button(action: {
    //                if selectedNotebook == nil {
    //                    return
    //                }
    //                usersState.deletingNotebook = selectedNotebook
    ////                usersState.presentDeleteConfirmation = true
    //                guard let temp = usersState.deletingNotebook else { return }
    //                usersState.deleteNotebookNew(ref: temp)
    //                usersState.deletingNotebook = nil
    //
    //            }) {
    //                Image(systemName: "trash")
    //                    .renderingMode(.original)
    //            }
    //        }
    //        .disabled(disableActions)
    //        .buttonStyle(PlainButtonStyle())
    //        .backgroundStyle(.bar)
    //        .padding()
    //
    //    }
    
}

//struct SearchedListView: View {
//
//    @Environment(\.editMode) private var editMode
//    @Environment(\.isSearching) private var isSearching
//    @Binding var selectedNotebook: Notebook.ID?
//    @Bindable var usersState: NotebooksListState
//
//    var body: some View {
//        if usersState.activeSearch {
//            Text("Results: \(usersState.searchResultCount)")
//                    .font(.caption)
//                    .padding(2)
//        }
//        List(selection: $selectedNotebook) {
//            NotebooksListGroupView(usersState: usersState, notebooks: $usersState.notebooks)
//
////            Section {
////                DisclosureGroup {
////
////                    NotebooksListGroupView(notebooks: $usersState.notebooks)
////
//////                    Text("Note 1")
//////                    Text("Note 2")
////                } label: {
////                    HStack {
////                        Image(systemName: "trash")
////                        Text("Recently Deleted")
////                            .font(.subheadline)
////                            .fontWeight(.bold)
////                            .foregroundColor(.gray)
////
////                    }
////                }
////                .tint(.gray)
//////                .disclosureGroupStyle(MyDisclosureStyle)
////
////            }
//
////            Section {
////                DisclosureGroup {
////                    Text("Note 1")
////                } label: {
////                    Text("Recently Deleted")
////                        .fontWeight(.bold)
////                        .foregroundColor(.gray)
////                        .padding(.top, 14)
////                }
////            } header: {
////                Text("Recently Deleted")
////                    .fontWeight(.bold)
////
////            }
//
//
//
////            DisclosureGroup("recently deleted") {
////                Text("Note 1")
////            }
////            Section("Recently Deleted") {
////                Text("Note 1")
////            }
//        }
//        .scrollDismissesKeyboard(.interactively)
//        .toolbar {
//
//            Button {
//                usersState.showHideRecentlyModified()
//            } label: {
//                Image(systemName: usersState.recentButtonIcon)
//            }
//
//            EditButton()
//        }
//        .onChange(of: isSearching) { newValue in
//            // on search active
//            if newValue {
//                // end editMode
//                editMode?.wrappedValue = .inactive
//                usersState.isShowingRecent = false
//            }
//
//            usersState.isSearching = newValue
////            print("isSearching, ", newValue)
////            selectedNotebook = nil
////            if newValue {
////                usersState.takeBackup()
////            } else {
////                usersState.restoreBackup()
////            }
//        }
//        .onChange(of: editMode?.wrappedValue) { newValue in
//            selectedNotebook = nil
////            if newValue == .active {
////
////            }
//        }
//    }
//
//}
//
//struct MyDisclosureStyle: DisclosureGroupStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack {
//            Button {
//                withAnimation {
//                    configuration.isExpanded.toggle()
//                }
//            } label: {
//                HStack(alignment: .firstTextBaseline) {
//                    configuration.label
//                    Spacer()
//                    Text(configuration.isExpanded ? "hide" : "show")
//                        .foregroundColor(.accentColor)
//                        .font(.caption.lowercaseSmallCaps())
//                        .animation(nil, value: configuration.isExpanded)
//                }
//                .contentShape(Rectangle())
//            }
//            .buttonStyle(.plain)
//            if configuration.isExpanded {
//                configuration.content
//            }
//        }
//    }
//}

struct AddNotesView: View {
    @Bindable var usersState: NotebooksListState
    
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

//
//struct MyTableRow: View {
//
//    @Bindable var usersState: NotebooksListState
//    @Binding var notebook: Notebook
//
//    var body: some View {
//
//        // normal
//        if notebook.containChildNotebooks {
//            DisclosureGroup(isExpanded: $notebook.isExpanded) {
//                NotebooksListGroupView(usersState: usersState, notebooks: $notebook.children)
//            } label: {
//                RowView(usersState: usersState, notebook: $notebook)
//            }
//        } else {
//            RowView(usersState: usersState, notebook: $notebook)
//        }
//    }
//}
//
//struct NotebooksListGroupView: View {
//    @Bindable var usersState: NotebooksListState
//    @Binding var notebooks: [Notebook]
//    @State private var isTargeted: Bool = true
//    var body: some View {
//        ForEach($notebooks) { $notebook in
//
////            Text(notebook.name)
//            MyTableRow(usersState: usersState, notebook: $notebook)
//
//            // normal
////            if notebook.containChildNotebooks {
////                DisclosureGroup(isExpanded: $notebook.isExpanded) {
////                    NotebooksListGroupView(usersState: usersState, notebooks: $notebook.children)
////                } label: {
////                    RowView(usersState: usersState, notebook: $notebook)
////                }
////            } else {
////                RowView(notebook: $notebook)
//////                        .opacity(isDragging && draggedItem == notebook ? 0.2 : 1.0)
//////                        .foregroundColor(isDragging && draggedItem == notebook ? .red : .orange)
//////                        .onDrag({
//////                            makeItemProvider(user: notebook)
//////                        }, preview: {
//////                            Text("Drag it-3r : \(notebook.name)")
//////                                .background(Color.orange)
//////                                .frame(width: 200, height: 30)
//////                        })
//////                        .onDrop(of: [.plainText], delegate: makeDropDelegate(user: notebook) )
////                   // .opacity(notebook.canShow ? 1 : 0)
////            }
//        }
//        .onMove(perform: move)
////        .onDrop(of: [.text], isTargeted: $isTargeted, perform: { providers in
////            print("ON DROP")
////            return true
////        })
//
//
////        .onInsert(of: [UTType.text]) { pos, prov in
////            print("\n-----> ignoring insert in model1")
////        }
//    }
//
//    @State private var operationTag = 1
//    @State private var draggedItem: Notebook?
//    @State private var isDragging = false
//    @State private var isCustomPreview = true
//
//
//    private func makeDropDelegate(user: Notebook) -> DropDelegate {
////        print("makeDropDelegate \(user.name)")
//        let operation: DropOperation
//        switch operationTag {
//        case 1:
//            operation = .move
//        default:
//            operation = .copy
//        }
//        return CommonDropDelegate(
//            currentItem: user,
//            operation: operation,
//            items: $notebooks,
//            draggedItem: $draggedItem,
//            onEntered: { _ in
//                print("Drop entered - \(user.name)")
//                withAnimation { isDragging = true }
//            },
//            onExit: {
//                print("drop exit")
//                withAnimation { isDragging = false }
//            },
//            onPerform: {
//                print("drop -onPerform")
//                withAnimation { isDragging = false }
//            }
//        )
//    }
//
//    private func makeItemProvider(user: Notebook) -> NSItemProvider {
//        print(#function)
//        print(user.name)
//        isDragging = true
//        draggedItem = user
//        return NSItemProvider(object: user.id.uuidString as NSItemProviderWriting)
//    }
//
//    func move(from source: IndexSet, to destination: Int) {
//        print(#function, source, destination)
//
////        notebooks.move(fromOffsets: source, toOffset: destination)
////
////        notebooks.first?.notebook.parent?.children?.move(fromOffsets: source, toOffset: destination)
////
////        usersState.move(notebooksM: &notebooks, from: source, to: destination)
//    }
//}
//
//
//struct RowView: View {
//    @Bindable var usersState: NotebooksListState
//    @Binding var notebook: Notebook
//    @State private var name: String = ""
//    @FocusState private var isFocused: Bool
//
//    @State private var showFileExistsAlert = false
//    @State private var showInvalidCharsAlert = false
//
//    @State private var isEditing = false {
//        didSet {
//            isFocused = isEditing
//        }
//    }
//
//    var disableActions: Bool {
//        return false
//    }
//
//    var body: some View {
//        HStack {
//            if isEditing {
//                TextField(text: $name) {
//                    Text("Notebook")
//                }
//                .background(Color.gray)
//                .focused($isFocused)
//            } else {
//                Text(notebook.name)
//                    .swipeActions(edge: .trailing) {
//                        Button(role: .destructive) {
////                            store.delete(message)
//
//                            usersState.deletingNotebook = notebook
//
//                            guard let temp = usersState.deletingNotebook else { return }
//                            usersState.deleteNotebookNew(ref: notebook)
//                            usersState.deletingNotebook = nil
//
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
////                        Button { store.flag(message) } label: {
////                            Label("Flag", systemImage: "flag")
////                        }
//                    }
//            }
//        }
//        .onAppear {
//            name = notebook.name
////            isFocused = false
//        }
//        .contextMenu {
//
//            if notebook.isDeleted {
//                Group {
//                    // restore
//                    Button(action: {
////                        usersState.insertBelow(ref: notebook)
//                    }) {
//                        Label("Restore", image: "arrow.uturn.backward")
////                        HStack {
////                            Text("Restore")
////                            Spacer()
////                            Image(systemName: "arrow.uturn.backward")
////                                .renderingMode(.original)
////                        }
//                    }
//
//                    // trash
//                    Button(role: .destructive, action: {
//                        usersState.deletingNotebook = notebook
//    //                    usersState.presentDeleteConfirmation = true
//
//                        usersState.deleteNotebookNew(ref: notebook)
//                        usersState.deletingNotebook = nil
//
//                    }) {
//                        HStack {
//                            Text("Delete")
//                            Spacer()
//                            Image(systemName: "trash")
//                                .renderingMode(.original)
//                        }
//                    }
//                }
//                .disabled(disableActions)
//            } else {
//                Group {
//                    RenameButton()
//                    // insert below
//                    Button(action: {
//                        usersState.insertBelow(ref: notebook)
//                    }) {
//                        Text("Add Below")
//                    }
//                    // insert inside
//                    Button(action: {
//                        usersState.insertInside(ref: notebook)
//                    }) {
//                        Text("Add Inside")
//                    }
//                    // trash
//                    Button(role: .destructive, action: {
//                        usersState.deletingNotebook = notebook
//    //                    usersState.presentDeleteConfirmation = true
//
//
//                        usersState.deleteNotebookNew(ref: notebook)
//                        usersState.deletingNotebook = nil
//
//                    }) {
//                        HStack {
//                            Text("Delete")
//                            Spacer()
//                            Image(systemName: "trash")
//                                .renderingMode(.original)
//                        }
//                    }
//                }
//                .disabled(disableActions)
//            }
//
//
//        }
//        .renameAction {
//            isEditing = true
//        }
//        .onChange(of: isEditing, perform: { newValue in
//            if newValue == false {
//                // on escape, reset content
//                name = notebook.name
//            }
//        })
//        .onSubmit {
//            if name == notebook.name {
//                isEditing = false
//                return
//            }
//            do {
//                try usersState.rename(for: notebook, newValue: name)
////                usersState.navTitle = name
//                isEditing = false
//            } catch NotebookBusinessError.alreadyExists {
//                showFileExistsAlert = true
//                isEditing = true
//            } catch NotebookBusinessError.invalidCharacters {
//                showInvalidCharsAlert = true
//                isEditing = true
//            } catch {
////                name = notebook.name
//            }
//        }
//        .confirmationDialog("Failed to rename file", isPresented: $showFileExistsAlert) {
//
//        } message: {
//            Text("filename already exists")
//        }
//        .confirmationDialog("Failed to rename file", isPresented: $showInvalidCharsAlert) {
//
//        } message: {
//            Text("filename contains unsupported characters")
//        }
//    }
//
//}
