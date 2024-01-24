//
//  MoveToView.swift
//  Notes 365
//
//  Created by kiran ipc on 20/12/23.
//

import SwiftUI

struct RestoreToView: View {
    @Environment(\.dismiss) var dismiss
    let notebook: Notebook
    @Binding var moveDestination: FileItem?
    @State var selectedItem: FileItem?
    @State var state = RestoreToViewState()
    @State var isFocused = true
    
    var body: some View {
        NavigationStack {
            VStack {
                List(selection: $moveDestination) {
                    ForEach($state.items) { $item in
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

private struct NestedFoldersView: View {
    @Binding var items: [FileItem]
    let notebook: Notebook
   
    var body: some View {
        ForEach($items) { $item in
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


@Observable
class RestoreToViewState {
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
