//
//  MoveToView.swift
//  Notes 365
//
//  Created by kiran ipc on 20/12/23.
//

import SwiftUI

struct FileItem: Hashable, Identifiable {
    
    var id: Self { self }
    var name: String
    var isExpanded = false
    var folderId: UUID = UUID()
    var children: [FileItem] = []
    var containsChildren: Bool {
        children.count > 0
    }
}


struct MoveToView: View {
    @Environment(\.dismiss) var dismiss
    let notebook: Notebook
    @State var state = MoveToState()
    @State var selectionValue:FileItem?
    @State var isFocused = true
    
    var body: some View {
        NavigationStack {
            VStack {
                
//                HStack {
//                    if notebook.isFolder {
//                        Label(notebook.name, systemImage: "folder")
//                    } else {
//                        Text(notebook.name)
//                    }
//                    
//                    Spacer()
//                }
//                .padding()
                
                List(selection: $selectionValue) {
                    ForEach($state.items) { $item in
                        
                        if notebook.parentId == nil {
                            // selected item is top level once. so, disable same level move
                            if item.containsChildren {
                                DisclosureGroup(isExpanded: $item.isExpanded) {
                                    NestedFoldersView(items: $item.children, notebook: notebook)
                                } label: {
                                    Label(item.name, systemImage: "folder")
                                        .foregroundStyle(.gray)
                                }
                                .selectionDisabled(true)
                            } else {
                                Label(item.name, systemImage: "folder")
                                    .foregroundStyle(.gray)
                                    .selectionDisabled(true)
                            }
                        } else {
                            if item.containsChildren {
                                DisclosureGroup(isExpanded: $item.isExpanded) {
                                    NestedFoldersView(items: $item.children, notebook: notebook)
                                } label: {
                                    Label(item.name, systemImage: "folder")
                                }
                            } else {
                                Label(item.name, systemImage: "folder")
                            }
                        }
                    }
                }
                .background(.tint)
            }
            
            .navigationTitle("Select a Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NestedFoldersView: View {
    @Binding var items: [FileItem]
    let notebook: Notebook
    
    func isSameLevelItem(_ item: FileItem) -> Bool {
        item.folderId == notebook.parentId
    }

    func isSameFolder(_ item: FileItem) -> Bool {
        if notebook.isFolder {
            return item.folderId == notebook.id
        } else {
            return false
        }
    }
    
    var body: some View {
        ForEach($items) { $item in
            if isSameLevelItem(item) {
                // disable only selection
                if item.containsChildren {
                    DisclosureGroup(isExpanded: $item.isExpanded) {
                        NestedFoldersView(items: $item.children, notebook: notebook)
                    } label: {
                        Label(item.name, systemImage: "folder")
                            .foregroundStyle(.gray)
                    }
                    .selectionDisabled(true)
                } else {
                    Label(item.name, systemImage: "folder")
                        .selectionDisabled(true)
                        .foregroundStyle(.gray)
                }
            } else if isSameFolder(item) {
                // disable selection and expantion
                if item.containsChildren {
                    DisclosureGroup(isExpanded: .constant(false)) {
                        // no need to populate nested items
                    } label: {
                        Label(item.name, systemImage: "folder")
                    }
                    .selectionDisabled(true)
                    .foregroundStyle(.gray)
                    .tint(.gray)
                } else {
                    Label(item.name, systemImage: "folder")
                        .selectionDisabled(true)
                        .foregroundStyle(.gray)
                }
            } else {
                if item.containsChildren {
                    DisclosureGroup(isExpanded: $item.isExpanded) {
                        NestedFoldersView(items: $item.children, notebook: notebook)
                    } label: {
                        Label(item.name, systemImage: "folder")
                    }
                    .selectionDisabled(false)
                } else {
                    Label(item.name, systemImage: "folder")
                        .selectionDisabled(false)
                }
            }
        }
    }
}


//#Preview {
//    MoveToView(, notebook: <#Notebook#>)
//}

@Observable
class MoveToState {
    let notebooksBusiness = BusinessFactory.createNotebooksFactory()
    var items: [FileItem] = []
    
    init() {
        // get folders list
        if let folders = try? notebooksBusiness.fetchAllFolders() {
            // populate hierarchy
            
            // insert notebooks as root
            var rootItem = FileItem(name: "Notebooks")
            rootItem.isExpanded = true
            let rootFolders = folders.filter { $0.parentId == nil }
            var childItems = [FileItem]()
            for rootFolder in rootFolders {
                var item = FileItem(name: rootFolder.name, folderId: rootFolder.id)
                populateChildren(&item, folders: folders)
                childItems.append(item)
            }
            rootItem.children = childItems
            
            items = [rootItem]
        }
    }
    
    func populateChildren(_ item: inout FileItem, folders: [NotebookB]) {
        let children = folders.filter { $0.parentId == item.folderId }
        var childItems = [FileItem]()
        for child in children {
            var item = FileItem(name: child.name, folderId: child.id)
            populateChildren(&item, folders: folders)
            childItems.append(item)
        }
        item.children = childItems
    }
    
}

struct ContentViewMoveToTest: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String
        var children: [FileItem]? = nil
        var description: String {
            
            
            switch children {
            case nil:
                return "📄 \(name)"
            case .some(let children):
                return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
            }
        }
    }
    let fileHierarchyData: [FileItem] = [
      FileItem(name: "users", children:
        [FileItem(name: "user1234", children:
          [FileItem(name: "Photos", children:
            [FileItem(name: "photo001.jpg"),
             FileItem(name: "photo002.jpg")]),
           FileItem(name: "Movies", children:
             [FileItem(name: "movie001.mp4")]),
              FileItem(name: "Documents", children: [])
          ]),
         FileItem(name: "newuser", children:
           [FileItem(name: "Documents", children: [])
           ])
        ]),
        FileItem(name: "private", children: nil)
    ]
    var body: some View {
        List(fileHierarchyData, children: \.children) { item in
            Label(item.description, systemImage: "folder")
        }
    }
}
