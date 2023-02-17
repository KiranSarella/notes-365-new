//
//  ContentView.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct NotebooksSidebarView: View {

    @EnvironmentObject var usersState: NotebooksListState
    @Binding var selectedNotebook: NotebookM?
    @State private var presentDeleteConfirmation = false
    
    var body: some View {
        
        if usersState.isEmpty {
            AddNotesView()
                .padding([.top], -100)
                .environmentObject(usersState)
        } else {
            VStack {
                List(selection: $selectedNotebook) {
                    NotebooksListGroupView(notebooks: $usersState.usersDB.notes)
                }
//                .listStyle(SidebarListStyle())
                .navigationTitle("Notebooks")
                .onChange(of: selectedNotebook) { newValue in
                    if let newValue = newValue {
                        usersState.navTitle = newValue.name
                    }
                }
                /*
                 ** IMP
                 
                 .listStyle(SidebarListStyle())
                 
                 this is required to show disclosureGroup when first item have no childs.
                 and only working with SidebarListStyle.
                 
                 DisclosureGroup(isExpanded: .constant(true)) {
                    ListGroupView(notebooks: $usersState.usersDB.notes)
                 } label: {
                 
                 }.disabled(true)
                 */
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    VStack {
                        getToolbarView()
                        Spacer()
                    }
                    .frame(height: 30)
                }
            }
            .frame(minWidth: 280, maxWidth: 500)
            .onDisappear {
                usersState.saveExpandedIds()
            }
        }
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
                    usersState.insertBelow(ref: selectedNotebook!.notebook)
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
                    usersState.insertInside(ref: selectedNotebook!.notebook)
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
                presentDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .renderingMode(.original)
            }
            .confirmationDialog("Are you sure?", isPresented: $presentDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    DispatchQueue.main.async {
                        usersState.deleteNotebook(ref: selectedNotebook!.notebook)
                        selectedNotebook = nil
                    }
                }
            } message: {
                Text("You cannot undo this action")
            }
        }
        .buttonStyle(PlainButtonStyle())
        .backgroundStyle(.bar)
        .padding(.horizontal)
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


struct NotebooksListGroupView: View {
    @Binding var notebooks: [NotebookM]
    var body: some View {
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
    }
    
}


struct RowView: View {
    @EnvironmentObject var usersState: NotebooksListState
    @Binding var notebook: NotebookM
    @State private var name: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var showFileExistsAlert = false
    @State private var showInvalidCharsAlert = false
    
    @State private var presentDeleteConfirmation = false
    
    @State private var isEditing = false {
        didSet {
            isFocused = isEditing
        }
    }
    
    var body: some View {
        HStack {
            if isEditing {
                TextField(text: $name) {
                    Text("Notebook")
                }
                .background(Color.white)
                .focused($isFocused)
            } else {
                Text(name)
            }
        }
        
        .onAppear {
            name = notebook.name
//            isFocused = false
        }
        .confirmationDialog("Are you sure?", isPresented: $presentDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                DispatchQueue.main.async {
                    usersState.deleteNotebook(ref: notebook.notebook)
                    //                        selectedNotebook = nil
                }
            }
        } message: {
            Text("You cannot undo this action")
        }
        .contextMenu {
            RenameButton()
            // insert below
            Button(action: {
                usersState.insertBelow(ref: notebook.notebook)
            }) {
                Text("Add Below")
            }
            // insert inside
            Button(action: {
                usersState.insertInside(ref: notebook.notebook)
            }) {
                Text("Add Inside")
            }
            
            // trash
            Button(role: .destructive,
                   action: {
                presentDeleteConfirmation = true
            }) {
                HStack {
                    Text("Delete")
                    Spacer()
                    Image(systemName: "trash")
                        .renderingMode(.original)
                }
                
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
                try usersState.rename(for: notebook.notebook, newValue: name)
                usersState.navTitle = name
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
