//
//  UsersState.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import Foundation
import SwiftUI
import Combine
import SwiftData
import Fakery

enum ListState {
    case all
    case recent
    case search
}

enum NotebooksFilterType {
    case none
    case searching
    case recentlyModified
}

enum ListSourceType: Equatable {
    case notebooks(NotebooksFilterType)
    case deletedItems
}



@Observable
class NotebooksListState {
    
    let notebooksBusiness: NotebooksRequester
//    let notebooksBusiness = BusinessFactory.createNotebooksFactoryNew(mock: true)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    var notebooks = [Notebook]()
    
    var notebooksHierarchy: Notebook = Notebook(id: UUID(), name: "")
    var deletedNotebooks = [Notebook]()
    
    var isLoading = false
    var listSourceType = ListSourceType.notebooks(.none)
    
    var searchText: String = ""
    var isSearching = false
    var searchResultCount: Int = 0
    var modifiedResultCount: Int = 0
    var deletedResultCount: Int = 0
    
    var canEnableDone: Bool {
        listSourceType == .deletedItems || listSourceType == .notebooks(.recentlyModified)
    }
    let searchTextPublisher = PassthroughSubject<String, Never>()
    var firstTimeAppear = true
    
    init(notebookBusiness: NotebooksRequester) {
        self.notebooksBusiness = notebookBusiness
        isLoading = true
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
            print("expandedIds.count: ", expandedIds.count)
        }
        
        setupSearchText()
        
        isLoading = false
    }
    
    func loadNotebooks() async {
        do {
            isLoading = true
            let results = try await notebooksBusiness.fetchAllNotebooks()
            showNotebooksList(notebooksB: results)
        } catch let error {
            print(error)
            isLoading = false
        }
    }
    
     func showNotebooksList(notebooksB: [NotebookB]) {
        // prepare dict
        var activeNotebooks = [UUID: NotebookB]()
        for result in notebooksB {
            if result.isDeleted { continue }
            activeNotebooks[result.id] = result
        }
        // topLevel
        guard let rootB = notebooksB.first(where: { $0.parentId == nil }) else {
            isLoading = false
            return
        }
        // notebooks
        let rootNode: Notebook = rootB.notebook()
        rootNode.populateChildren(from: activeNotebooks, expandedIds: expandedIds)
        
        self.notebooksHierarchy = rootNode
        isLoading = false
    }
   
    func saveExpandedIds() {
        UserDefaults.standard.set(Array(expandedIds), forKey: "notes365.expandedIds")
    }
    
//    func removeAllExpandedIds() {
//        expandedIds.removeAll()
//        saveExpandedIds()
//    }
    
    func waitTillFetching() {
        isLoading = true
    }
    
    var isEmpty: Bool {
        notebooksHierarchy.childrenCount == 0
    }
    
    private func addFirstNotes() async {
        do {
            let _ = try notebooksBusiness.createNotebook().notebook()
            await loadNotebooks()
        } catch let error {
            print(error)
        }
    }
    
    var isRootCreated: Bool {
        notebooksHierarchy.name == "root"
    }
    
    var isCreatingNotebook = false
    
    func createNotebook() async {
        if isRootCreated {
            if let lastNotebook = notebooksHierarchy.children.last {
                insertBelow(ref: lastNotebook)
            } else {
                insertInside(ref: notebooksHierarchy)
            }
        } else {
            await addFirstNotes()
        }
    }
    
    func insertBelow(ref notebook: Notebook) {
        guard let parent = notebook.parent else { return }
        let children = parent.children.map { $0.notebookB() }
        do {
            let newNotebookB = try notebooksBusiness.createNotebook(inside: parent.notebookB(), below: notebook.id, children: children)
            let newNotebook = newNotebookB.notebook()
            newNotebook.updateParent(parent)
            try notebook.parent?.insertChild(notebook: newNotebook, below: notebook.id)
        } catch let error {
            print(error)
        }
    }
    
    func insertInside(ref notebook: Notebook) {
        let children = notebook.children.map { $0.notebookB() }
        do {
            let newNotebookB = try notebooksBusiness.createNotebook(inside: notebook.notebookB(), below: nil, children: children)
            let newNotebook = newNotebookB.notebook()
            newNotebook.updateParent(notebook)
            notebook.appendChildren(notebook: newNotebook)
        } catch let error {
            print(error)
        }
    }
    
    func delete(notebook: Notebook) {
        guard let parent = notebook.parent else { return }
        do {
            try notebooksBusiness.deleteNotebook(notebook: notebook.notebookB(), parent: parent.notebookB())
        } catch let error {
            print(error)
            return
        }
        // delete from UI
        notebook.parent?.deleteChildren(where: notebook.id)
//        guard let newDate = Calendar.current.date(byAdding: .month, value: -2, to: Date()) else { return }
        // mark deleted date
        notebook.deletedDate = Date()
        // add to deleted list
        deletedNotebooks.insert(notebook, at: 0)
    }
    
    func rename(for notebook: Notebook, newValue: String) throws {
        try notebooksBusiness.rename(notebook: notebook.notebookB(), newValue: newValue, siblings: notebook.parent!.children.map({$0.notebookB()}))
        notebook.name = newValue
    }
    
}

// MARK: - Notebooks Filter
extension NotebooksListState {
    
    func updateExpandedIds(id: String, isExpanded: Bool) {
        if isExpanded {
            expandedIds.insert(id)
        } else {
            expandedIds.remove(id)
        }
    }
    
    func setupSearchText() {
        
        searchTextPublisher
            .map({ (string) -> String? in
                if string.count < 2 {
//                    self.usersDB.notes = []
                    self.searchResultCount = 0
                    return nil
                }
                return string
            })
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .compactMap{ $0 }
            .sink { status in
//                print(status)
            } receiveValue: { [self] (searchField) in
                searchItems(searchField)
            }.store(in: &subscription)
    }
    
    var activeSearch: Bool {
        isSearching && searchText.count >= 2
    }
    
    func searchItems(_ text: String) {
        
        if isSearching == false {
            return
        }
        
        if text.count == 0 {
            searchResultCount = 0
        } else {

            var resultsCount = 0
            
            func canAddNotebook(note: inout Notebook) -> Bool {
                
                // for expansion: isExpanded
                // go deep first, if deep return true, then mark current as true
                // if deep is false, then check current name condition
                
                // for canShow:
                // if name contains search str - true else false
                
                
                // check nested items
                var visibleChildsStatus = Set<Bool>()
                // if children exists
                if note.children != nil {
                    let count = note.children.count
                    for i in 0..<count {
                        let anyVisibleChildren = canAddNotebook(note: &note.children[i])
                        visibleChildsStatus.insert(anyVisibleChildren)
                    }
                }
                // check if search str contains in file name
                if note.name.lowercased().contains(text.lowercased()) {
                    note.canShow = true
                    resultsCount += 1
                } else {
                    note.canShow = false
                }
                
                // if any child notebooks are visible, expanded should be yes
                if visibleChildsStatus.contains(true) {
                    note.isExpanded = true
                } else {
                    note.isExpanded = false
                }
                
                // status is used for parent node
                if note.isExpanded || note.canShow {
                    return true
                }
                
                return false
            }
            
            var notebooksList = self.notebooks
            
            for i in 0..<notebooksList.count {
                _ = canAddNotebook(note: &notebooksList[i])
            }
            // update
            self.notebooks = notebooksList
            searchResultCount = resultsCount
        }
    }
    
    
}

// MARK: - recent notebooks list
extension NotebooksListState {
    
    var recentButtonIcon: String {
//        isShowingRecent ? "clock.fill" : "clock"
        listSourceType == .notebooks(.recentlyModified) ? "clock.arrow.circlepath" : "clock.arrow.circlepath"
    }
    
    func hideRecentlyModified() {
        listSourceType = .notebooks(.none)
    }
    
    func showRecentlyModified() {
        // as notebooks can be modify, only backup expanded ids
        var resultsCount = 0
        func canAddNotebook(note: inout Notebook) -> Bool {
            // for expansion: isExpanded
            // go deep first, if deep return true, then mark current as true
            // if deep is false, then check current name condition
            
            // for canShow:
            // if name contains search str - true else false
            
            // check nested items
            var visibleChildsStatus = Set<Bool>()
            // if children exists
            if note.containChildNotebooks {
                let count = note.children.count
                for i in 0..<count {
                    let anyVisibleChildren = canAddNotebook(note: &note.children[i])
                    visibleChildsStatus.insert(anyVisibleChildren)
                }
            }
            
            print(note.name, note.modifiedDate)
            
            // check if search str contains in file name
            if note.modifiedDate >= Calendar.current.date(byAdding: .day, value: -2, to: Date())! {
                note.canShow = true
                resultsCount += 1
            } else {
                note.canShow = false
            }
            
            // if any child notebooks are visible, expanded should be yes
            if visibleChildsStatus.contains(true) {
                note.isExpanded = true
            } else {
                note.isExpanded = false
            }
            
            // status is used for parent node
            if note.isExpanded || note.canShow {
                return true
            }
            
            return false
        }
        
        var notebooksList = self.notebooks
        
        for i in 0..<notebooksList.count {
            _ = canAddNotebook(note: &notebooksList[i])
        }

        self.notebooks = notebooksList
        modifiedResultCount = resultsCount
        
        listSourceType = .notebooks(.recentlyModified)
    }
    

}

// MARK: - recently deleted
extension NotebooksListState {
    
    var recentlyDeletedButtonIcon: String {
//        isShowingRecentlyDeleted ? "trash.fill" : "trash.square"
        listSourceType == .deletedItems ? "trash" : "trash"
    }
  
    func hideRecentlyDeleted() {
        listSourceType = .notebooks(.none)
    }
    
    func showRecentlyDeleted() {
        deletedResultCount = deletedNotebooks.count
        listSourceType = .deletedItems
    }
    
    func checkOldItemsToDelete() {
        // delete date exceeded notebooks
//        notebookBusiness.deleteDateExceededNotebooks(deletedNotebooks: &deletedNotebooks)
    }
    
}


extension NotebookB {
    
    func notebook() -> Notebook {
        
        let notebook = Notebook(id: id, name: name)
        notebook.createdDate = createdDate
        notebook.modifiedDate = modifiedDate
        notebook.deletedDate = deletedDate
        
        notebook.parentId = parentId
        notebook.childrenIds = childrenIds
        
        return notebook
    }
    
}

extension Notebook {
    
    func notebookB() -> NotebookB {
        let notebookB = NotebookB(id: id, name: name)
        notebookB.parentId = parent?.id
        notebookB.childrenIds = children.map { $0.id }
        
        notebookB.createdDate = createdDate
        notebookB.modifiedDate = modifiedDate
        notebookB.deletedDate = deletedDate
        return notebookB
    }
    
}
