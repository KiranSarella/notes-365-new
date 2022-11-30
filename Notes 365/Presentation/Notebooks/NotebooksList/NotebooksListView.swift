//
//  ContentView.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct NotebooksListView: View {

    @EnvironmentObject var usersState: NotebooksListState
    
    @Binding var userSelectionState: SelectedNotebookInfo?
    @Binding var selectedUser: NotebookM?
    
    @State private var selectedUserID: NotebookM.ID?
    
    @State var isExpanded = true
    @State var isLoading = true
    @State private var isPresentingConfirm: Bool = false
    @State var presentingPurchasesView = false
    
    @State private var multiSelection = Set<NotebookM>()
    
    var body: some View {
        VStack {
            
//            List(usersState.usersDB.notes, id:\.self, children: \.children, selection: $multiSelection) { item in
//                Text("\(item.name)")
//            }
            
            List(selection: $selectedUser) {
                ListGroupView(notebooks: $usersState.usersDB.notes)
//                DisclosureGroup(isExpanded: .constant(true)) {
//
//                } label: {
//
//                }.disabled(true)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(selectedUser?.name ?? "Notes 365")
            /*
             ** IMP
             this is required to show disclosureGroup when first item have no childs.
             and only working with SidebarListStyle.
             */

//            List(selection: $selectedUserID) {
//                DisclosureGroup(isExpanded: $isExpanded) {
//                    ForEach($usersState.usersDB.notes) { $notebook in
//
//                        if notebook.containChildNotebooks {
//                            DisclosureGroup(isExpanded: $notebook.isExpanded) {
//                                ForEach($usersState.usersDB.notes) { $notebook in
//                                    Text(notebook.name)
//                                }
//                            } label: {
//                                Text(notebook.name)
//                            }
//                        } else {
//                            Text(notebook.name)
//                        }
//                    }
//                } label: {
//
//                }
//
//            }
            
//            List(selection: $selectedUser) {
//
//                DisclosureGroup(isExpanded: $isExpanded) {
//                    NotesListView(users: $usersState.usersDB.notes,
//                                  selectedUser: $selectedUser,
//                                  userSelectionState: $userSelectionState)
//                    .environmentObject(usersState)
//                } label: {
//
//                }
//            }
//            .onDisappear {
//
//                // save state
//                userSelectionStateDB = userSelectionState
//
//                // TODO: -
//                usersState.saveSelectionState() // to persiste selection
//
//                directoryManager.prepareFolderPaths()
//            }
            
            // show add notes view if list is empty
            if isLoading == false && usersState.usersDB.notes.isEmpty {
                
                AddNotesView()
                    .padding([.top], -100)
                    .environmentObject(usersState)
            } else {
#if os(macOS)
                getToolbarView()
                
#elseif os(iOS)
                
                if UIDevice.current.userInterfaceIdiom == .pad ||
                    UIDevice.current.userInterfaceIdiom == .mac {
                    
                    getToolbarView()
                }
#endif
            }
        }
        .frame(minWidth: 280, maxWidth: 500)
        
    }
    
    
    func getToolbarView() -> some View {
        // tool bar
        HStack(spacing: 20) {
            
            Group {
                // insert below
                Button(action: {
                    
                    if usersState.canAddNotebook() == false {
                        // show purchase window
                        self.presentingPurchasesView.toggle()
                        return
                    }
                    usersState.insertUserBelowSelection()
                }) {
                    //                Image(systemName: "arrow.down")
                    //                    .renderingMode(.original)
                    Text("Add Below")
                }
                // insert inside
                Button(action: {
//                    print(multiSelection)
                    usersState.insertInside(ref: selectedUser!.notebook)
                    return
                    
                    if usersState.canAddNotebook() == false {
                        // show purchase window
                        self.presentingPurchasesView.toggle()
                        return
                    }
                    usersState.insertInsideSelection()
                }) {
                    //                Image(systemName: "arrow.turn.down.right")
                    //                    .renderingMode(.original)
                    Text("Add Inside")
                }
            }
            .sheet(isPresented: $presentingPurchasesView, content: {
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            self.presentingPurchasesView.toggle()
                        } label: {
                            Text("Close")
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                    PurchasesView()
                }
                
            })
            .buttonStyle(.bordered)
            Spacer()
            // trash
            Button(action: {
               isPresentingConfirm = true
            }) {
                Image(systemName: "trash")
                    .renderingMode(.original)
            }
            .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                Button("Delete", role: .destructive) {
                    DispatchQueue.main.async {
                        usersState.deleteUser()
                        userSelectionState = nil
                    }
                }
            } message: {
                Text("You cannot undo this action")
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
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
        }
    }
}


struct ListGroupView: View {
    
    @Binding var notebooks: [NotebookM]
    
    var body: some View {
        
        ForEach($notebooks, id: \.self) { $notebook in
            if notebook.containChildNotebooks {
                DisclosureGroup(isExpanded: $notebook.isExpanded) {
                    ListGroupView(notebooks: $notebook.children.unwrap()!)
                } label: {
                    Text(notebook.name)
                }
            } else {
                Text(notebook.name)
//                NavigationLink(notebook.name, value: notebook)
            }
        }
    }
    
}


struct NotesListView: View {
    
    @EnvironmentObject var usersState: NotebooksListState
    var parentUser: NotebookM?
    @Binding var users: [NotebookM]
    @Binding var selectedUser: NotebookM?
    @Binding var userSelectionState: SelectedNotebookInfo?
    
    var body: some View {
        ForEach($users) { user in
            RowView(user: user, selectedUser: $selectedUser, showDisclosure: user.wrappedValue.containChildNotebooks, userSelectionState: $userSelectionState)
        }
    }
    
}

struct RowView: View {
    @Binding var user: NotebookM
    @Binding var selectedUser: NotebookM?
    var showDisclosure: Bool
    @Binding var userSelectionState: SelectedNotebookInfo?
    var body: some View {
        if showDisclosure {
            GroupedView(user: $user, selectedUser: $selectedUser, userSelectionState: $userSelectionState)
        } else {
            Text(user.name)
//            HeadingView(user: $user, userSelectionState: $userSelectionState, selectedUser: $selectedUser)
        }
    }
}

struct HeadingView: View {
    
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var user: NotebookM
    @Binding var userSelectionState: SelectedNotebookInfo?
    @Binding var selectedUser: NotebookM?
    @State private var isActionSheetPresented = false
    @State private var isEditing = false
    @State private var isHover = false
    enum Field: Hashable {
        case name
    }
    @FocusState private var focusedField: Field?
    @State private var editingFileName: String = ""
    var isSelected: Bool {
        return selectedUser == user
    }
    var showOptions: Bool {
        return isHover && isSelected
    }
    let titleFont: CGFloat = 14
    @State private var showFileExistsAlert = false
    @State private var showInvalidCharsAlert = false
    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: $editingFileName, onCommit: {
                    DispatchQueue.main.async {
                        isEditing = false
                    }
                })
                .font(Font.system(size: titleFont))
                .focused($focusedField, equals: .name)
            } else {
                Text(user.name + "                                         ")
                    .font(Font.system(size: titleFont))
                    .foregroundColor(isSelected ? Color.blue : Color.primary)
            }
            Spacer()
            Button {
                DispatchQueue.main.async {
                    // assign existing file name to editing variable
                    editingFileName = user.name
                    
                    isEditing = true
                    focusedField = .name
                }
            } label: {
                //                    Image(systemName: "ellipsis.circle.fill")
                Image(systemName: "pencil.circle")
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
            .opacity(showOptions ? 1 : 0)
        }
        .onAppear {
            self.editingFileName = user.name
        }
        .onHover(perform: { status in
            isHover = status
        })
        .onTapGesture {
//            let userSelectionStateValue = SelectedNotebookInfo(notebook: user, levels: levels, index: index)
//            userSelectionState = userSelectionStateValue
        }
        .buttonStyle(.plain)
        .confirmationDialog("Failed to rename file", isPresented: $showFileExistsAlert) {
            
        } message: {
            Text("filename already exists")
        }
        .confirmationDialog("Failed to rename file", isPresented: $showInvalidCharsAlert) {
            
        } message: {
            Text("filename contains unsupported characters")
        }
        .onChange(of: isEditing) { newValue in
            if newValue == false {
                // if file name not modified
                if editingFileName == user.name {
                    return
                }
                if editingFileName.contains(":") {
                    showInvalidCharsAlert = true
                    return
                }
                do {
                   try usersState.renameNotebook(editingFileName: editingFileName)
                } catch {
                    // show alert
                    showFileExistsAlert = true
                    return
                }
            }
        }
    }
    
}

struct GroupedView: View {
    @Binding var user: NotebookM
    @Binding var selectedUser: NotebookM?
    @Binding var userSelectionState: SelectedNotebookInfo?
    var body: some View {
        DisclosureGroup(isExpanded: $user.isExpanded) {
            NotesListView(parentUser: user, users: $user.children.unwrap()!, selectedUser: $selectedUser, userSelectionState: $userSelectionState)
        } label: {
            Text(user.name)
//            HeadingView(user: $user, userSelectionState: $userSelectionState, selectedUser: $selectedUser)
        }
    }
}
