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

extension  Notification.Name {
    public static let ExpandCollapseNotification = Notification.Name("com.notes365.ExpandCollapseNotification")
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
    
//    static let shared: NotebooksListState = NotebooksListState()
    
    var modelContext: ModelContext?
    
    let notebooksBusiness = BusinessFactory.createNotebooksFactoryNew(mock: true)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    var notebooks = [Notebook]()
    
    var notebooksHierarchy: Notebook = Notebook(id: UUID(), name: "")
    var deletedNotebooks = [Notebook]()
    
    var isLoading = false
//    var notesHierarchy: NotebooksHierarchy
    
    var listSourceType = ListSourceType.notebooks(.none)
    
    var searchText: String = ""
    var isSearching = false
    var searchResultCount: Int = 0
    
//    @Published var isShowingRecent = false
    var modifiedResultCount: Int = 0
    
//    @Published var isShowingRecentlyDeleted = false
    var deletedResultCount: Int = 0
    
//    private var backupNotebooks = [Notebook]()
//    private var backupExpandedIds = Set<String>()
    
    let notebooksPath = Constants.notebooksFolderName
    
    var canEnableDone: Bool {
        listSourceType == .deletedItems || listSourceType == .notebooks(.recentlyModified)
    }
    
    let searchTextPublisher = PassthroughSubject<String, Never>()
    
    var firstTimeAppear = true
    
//    var timelineCreatorBusiness = TimelineBusiness(path: EnvironmentState.shared.basePathURL)
    
    init() {
        isLoading = true
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        
        // observe after initial hierarcy is constructed
        NotificationCenter.default.addObserver(self, selector: #selector(listenExpandCollapseNotification(_:)), name: .ExpandCollapseNotification, object: nil)
        
        setupSearchText()
        
        isLoading = false
    }
    
    func loadNotebooks() {
        Task {
            do {
                let results = try await notebooksBusiness.fetchAllNotebooks()
                showNotebooksList(notebooksB: results)
            } catch let error {
                print(error)
            }
        }
    }
    
    func showNotebooksList(notebooksB: [NotebookB]) {
        
        // prepare dict
        var dict = [UUID: NotebookB]()
        for result in notebooksB {
            dict[result.id] = result
        }
        // topLevel
        guard let rootB = notebooksB.first(where: { $0.parentId == nil }) else {
            isLoading = false
            return
        }
//                    .sorted { $0.orderID < $1.orderID }
//            topLevels.removeAll(where: { $0.isDeleted })
        
        // notebooks
        let rootNode: Notebook = rootB.notebook()
        rootNode.populateChildren(from: dict)
        
        self.notebooksHierarchy = rootNode
        isLoading = false
    }
    
    private func formNotebooksHierarchy(from notebooksData: [NotebookB]) -> Notebook? {
        // prepare dict
        var dict = [UUID: NotebookB]()
        for result in notebooksData {
            dict[result.id] = result
        }
        guard let rootNotebookData = notebooksData.first(where: { $0.parentId == nil }) else { return nil }
        let rootNotebook = rootNotebookData.notebook()
        rootNotebook.populateChildren(from: dict)
        return rootNotebook
    }
   
    
    func initialFetch() {
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
    }
    
    func saveExpandedIds() {
        UserDefaults.standard.set(Array(expandedIds), forKey: "notes365.expandedIds")
    }
    
    func waitTillFetching() {
        isLoading = true
    }
    
    func fetchNotebooks() {
//        Task {
//            isLoading = true
////            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            self.notebooks = await notebookBusiness.fetchNotebooks() ?? []
//            self.deletedNotebooks = await notebookBusiness.fetchDeletedNotebooks() ?? []
//            isLoading = false
//            checkOldItemsToDelete()
//        }
    }
    
    var isEmpty: Bool {
        notebooksHierarchy.childrenCount == 0
//        notebooks.count == 0
    }
    
    func addFirstNotes() {
        do {
            let _ = try notebooksBusiness.createNotebook().notebook()
            loadNotebooks()
//            withAnimation {
//                notebooks = [newNotebook]
//            }
        } catch let error {
            print(error)
        }
    }
    
    func insertBelow(ref notebook: Notebook) {
        
        guard let parent = notebook.parent else { return }
        let children = parent.children.map { $0.notebookB() }
        guard let position: Int = parent.children.firstIndex(of: notebook) else { return }
        
        do {
            let newNotebookB = try notebooksBusiness.createNotebook(inside: parent.notebookB(), at: position, children: children)
            
            let newNotebook = newNotebookB.notebook()
            try notebook.parent?.insertChild(notebook: newNotebook, at: position)
            
        } catch let error {
            print(error)
        }
    }
    
    func insertInside(ref notebook: Notebook) {
        let children = notebook.children.map { $0.notebookB() }
        do {
            let newNotebookB = try notebooksBusiness.createNotebook(inside: notebook.notebookB(), at: nil, children: children)
            let newNotebook = newNotebookB.notebook()
            newNotebook.updateParent(notebook)
            notebook.appendChildren(notebook: newNotebook)
        } catch let error {
            print(error)
        }
    }
    
   
    
//    private func getNotebook(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook? {
//        
//        // goto last level list
//        var notebooksList: [Notebook]? = notebooks
//        for level in selectedLevels {
//            notebooksList = notebooksList?[level].children
//        }
//        // get notebook from last list
//        return notebooksList?[selectedIndex]
//    }
    
    
//    func deleteNotebook(ref notebook: Notebook) {
//        // delete from hierarchy
//        if let parent = notebook.parent {
//            // delete notebook ref
//            parent.children?.removeAll(where: { $0 == notebook })
//        } else {
//            // base level
//            // delete notebook ref
//            notebooks.removeAll(where: { $0 == notebook })
//            // delete object
//            notebooks.removeAll(where: { $0.id == notebook.id })
//        }
//        // delete physical file
//        notebookBusiness.deleteNotebook(notebook: notebook)
//        // persist
//        notebookBusiness.persist(notebooks: notebooks)
//    }
    
    func delete(notebook: Notebook) {
        
        guard let modelContext = modelContext else { return }
        
        // delete from hierarchy
        if let parent = notebook.parent {
            // inner item
            // delete notebook
            parent.deleteChildren(where: notebook.id)
        } else {
            // base level
            // delete notebook
            notebooks.removeAll(where: { $0 == notebook })
        }
          
        guard let newDate = Calendar.current.date(byAdding: .month, value: -2, to: Date()) else { return }
        
        // mark deleted date
        notebook.deletedDate = newDate//Date()
        // persist
        notebook.saveNotebookData(modelContext)
        
        // add to deleted list
        deletedNotebooks.insert(notebook, at: 0)
    }
    
    
    func rename(for notebook: Notebook, newValue: String) throws {
//        // validate characters
//        if newValue.contains(":") {
//            throw NotebookBusinessError.invalidCharacters
//        }
        
        // check if already same file name exists
        if let parent = notebook.parent {
            if isAlreadyExists(fileName: newValue, in: parent.children) {
                throw NotebookBusinessError.alreadyExists
            }
        } else {
            if isAlreadyExists(fileName: newValue, in: notebooks) {
                throw NotebookBusinessError.alreadyExists
            }
        }
        // store name
        notebook.name = newValue
        // update in notebooksData and save
        notebook.notebookData.name = newValue
        try modelContext?.save()
        
//        // persist changes
//        notebookBusiness.persist(notebooks: notebooks)
    }

    
//    func move(notebooks: inout [Notebook], from source: IndexSet, to destination: Int) {
//        // move references
//        if notebooks.first?.parent?.children != nil {
//            notebooks.first?.parent?.children?.move(fromOffsets: source, toOffset: destination)
//        } else {
//            self.notebooks.move(fromOffsets: source, toOffset: destination)
//        }
//        // move structs
//        notebooks.move(fromOffsets: source, toOffset: destination)
//        
//        // persist refernce list
//        notebookBusiness.persist(notebooks: self.notebooks)
//    }
    
    
    private func isAlreadyExists(fileName: String, in siblings: [Notebook]) -> Bool {
        return siblings.contains(where: { $0.name == fileName })
    }
    
    private func generateFileName(at siblings: [Notebook]?) -> String {
        var count = 1
        var fileName = "Notebook \(count)"
        if let siblings = siblings {
            while isAlreadyExists(fileName: fileName, in: siblings) {
                count += 1
                fileName = "Notebook \(count)"
            }
        }
        return fileName
    }
    
    // MARK: -
    
    func getFolderNamesPath(levels: [Int]) -> String {
        notebooksPath
    }
    
    
    // MARK: -
    func saveSelectionState() {
        
    }
    
    func getNotebook(uuid: UUID) -> Notebook? {
        
        let tripPredicate = #Predicate<NotebookData> {
            $0.id == uuid
        }
        
        var descriptor = FetchDescriptor(predicate: tripPredicate)
        descriptor.fetchLimit = 1

        do {
            let trips = try modelContext?.fetch(descriptor)
            if let noteData = trips?.first {
                return Notebook(noteData)
            }
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
}

// MARK: - Notebooks Filter
extension NotebooksListState {
    
    @objc func listenExpandCollapseNotification(_ sender: Notification) {
        guard let userInfo = sender.userInfo else { return }
        
        guard
            let id = userInfo["id"] as? UUID,
            let isExpanded = userInfo["isExpanded"] as? Bool
        else { return }
        
        if isExpanded {
            expandedIds.insert(id.uuidString)
        } else {
            expandedIds.remove(id.uuidString)
        }
        
        //        print(expandedIds)
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
