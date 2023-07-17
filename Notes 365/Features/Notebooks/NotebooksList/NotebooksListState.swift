//
//  UsersState.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import Foundation
import SwiftUI
import Combine


enum ListState {
    case all
    case recent
    case search
}

extension  Notification.Name {
    public static let ExpandCollapseNotification = Notification.Name("com.notes365.ExpandCollapseNotification")
}


@Observable
class NotebooksListState {
    
    let notebookBusiness = NotebooksListBusiness(EnvironmentState.shared.basePathURL)
    let recentNotebooks = RecentNotebooksList(EnvironmentState.shared.basePathURL)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    var notebooks = [Notebook]()
    private var deletedNotebookRestorePaths = [String: [String]]()
    var deletedNotebooks = [Notebook]()
    
    var deletedNotes = DeletedNotebooks()
    
//    @Published var notesHierarchy: NotebooksHierarchy
    
    var searchText: String = ""
    var isSearching = false
    var searchResultCount: Int = 0
    
    var isShowingRecent = false
    
    var presentDeleteConfirmation = false
    var deletingNotebook: Notebook? = nil
    
//    private var backupNotebooks = [NotebookM]()
//    private var backupExpandedIds = Set<String>()
    
    let notebooksPath = Constants.notebooksFolderName
    
//    @Published var isLoaded = false
    
    init() {
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        
        // create notesHierarchy with actual notebook objects
        notebooks = notebookBusiness.retrieveNotebooks() ?? []
        
//        // construct deleted notebooks list
//        if let deletedNotesData = notebookBusiness.retrieveDeletedNotebooks() {
//            deletedNotes = deletedNotesData
//            let deletednotesList = NotebooksHierarchy.constructHierarchy(notebooks: deletedNotebooks, expandedIds: expandedIds, isDeleted: true)
//            notesHierarchy.deletedNotes = deletednotesList
//        }
        
        // observe after initial hierarcy is constructed
        NotificationCenter.default.addObserver(self, selector: #selector(listenExpandCollapseNotification(_:)), name: .ExpandCollapseNotification, object: nil)
        
        setupSearchText()
    }
    
    @MainActor
//    func loadData() async {
//        isLoaded = false
//        // create notesHierarchy with actual notebook objects
//        if let notebooks = await notebookBusiness.readDocument() {
//            let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
//            usersDB = NotebooksHierarchy(notes: notesList)
//        }
//
//        notebookBusiness.newContentAvailalble = { [self] in
//            print("notebookBusiness.newContentAvailalble")
//            dump(notebookBusiness.notebooks)
//            let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebookBusiness.notebooks, expandedIds: self.expandedIds)
//            usersDB = NotebooksHierarchy(notes: notesList)
//        }
//
//        isLoaded = true
//    }
    
    func initialFetch() {
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        
        // create notesHierarchy with actual notebook objects
        notebooks = notebookBusiness.retrieveNotebooks() ?? []
    }

    func reloadNotebooksList() {
        // if notebooks is empty, try to reload on demand
        if notebooks.count == 0 || notebookBusiness.isReloadRequired() {
            // clear
            notebooks = notebookBusiness.retrieveNotebooks() ?? []
        }
        
        // refresh recent list
        recentNotebooks.populateData()
    }
    
    func saveExpandedIds() {
        UserDefaults.standard.set(Array(expandedIds), forKey: "notes365.expandedIds")
    }
    
    
//    func fetchExpandedIds() {
//        expandedIds = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? Set<UUID> ?? Set<UUID>()
//    }
    
    var isEmpty: Bool {
        notebooks.count == 0
    }
    
    func addFirstNotes() {
        let notebook = createNotebook(parent: nil)
        // create file
        notebookBusiness.addFirst(notebook: notebook)
        // add to heirarchy
        notebooks.append(notebook)
        // persist hierarchy
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func insertBelow(ref notebook: Notebook) {
        // create actual notebook
        let (childNotebook, parent, index) = insertBelow(notebook: notebook)
        // persist
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    // return - (newNotebook, parent, ref notebook Index)
    private func insertBelow(notebook: Notebook) -> (new: Notebook, parent: Notebook?, refIndex: Int) {
        if let parent = notebook.parent {
            // get index of current notebook
            let index = parent.children!.firstIndex(of: notebook)!
            let childNote = insertInside(notebook: parent, below: index)
            return (childNote, parent, index)
        } else {
            // base level
            let fullPath = notebooksPath
            let newNotebook = createNotebook(parent: notebook.parent)
            // get index of current notebook
            let index = notebooks.firstIndex(of: notebook)!
            // create object
            notebooks.insert(newNotebook, at: index + 1)
            // create phycical file
            notebookBusiness.insertBelow(notebook: newNotebook)
            return (newNotebook, nil, index)
        }
    }
    
    func insertInside(ref notebook: Notebook) {
        // create actual notebook in the storage and hierarchy
        let childNotebook = insertInside(notebook: notebook)
        // persist
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    private func insertInside(notebook: Notebook, below index: Int? = nil) -> Notebook {
        let fullPath = notebooksPath
        let newNotebook = createNotebook(parent: notebook)
        
        //        let newNotebook = createNotebook(atPath: fullPath)
        newNotebook.parent = notebook
        
        if let index = index {
            // create object
            notebook.children!.insert(newNotebook, at: index + 1)
            // ..folder already exists
        } else if notebook.children == nil {
            // create object
            notebook.children = [newNotebook]
            // create folder
            //            dataManager.createFolder(fullPath)
        } else {
            // create object
            notebook.children?.append(newNotebook)
            // ..folder already exists
        }
        // create phycical file
        notebookBusiness.insertInside(notebook: newNotebook)
        return newNotebook
    }
    
    func createNotebook(parent: Notebook?) -> Notebook {
        
        // generate non existed file name at that level
        var fileName = ""
        if let parent = parent {
            fileName = generateFileName(at: parent.children)
        } else {
            fileName = generateFileName(at: notebooks)
        }
        
        return Notebook(id: UUID(), name: fileName)
    }
    
    private func getNotebook(levels selectedLevels: [Int], index selectedIndex: Int) -> Notebook? {
        
        // goto last level list
        var notebooksList: [Notebook]? = notebooks
        for level in selectedLevels {
            notebooksList = notebooksList?[level].children
        }
        // get notebook from last list
        return notebooksList?[selectedIndex]
    }
    
    
    func deleteNotebook(ref notebook: Notebook) {
        // delete from hierarchy
        if let parent = notebook.parent {
            // delete notebook ref
            parent.children?.removeAll(where: { $0 == notebook })
        } else {
            // base level
            // delete notebook ref
            notebooks.removeAll(where: { $0 == notebook })
            // delete object
            notebooks.removeAll(where: { $0.id == notebook.id })
        }
        // delete physical file
        notebookBusiness.deleteNotebook(notebook: notebook)
        // persist
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func deleteNotebookNew(ref notebook: Notebook) {
        // delete from hierarchy
        if let parent = notebook.parent {
            // delete notebook ref
            parent.children?.removeAll(where: { $0 == notebook })
        } else {
            // base level
            // delete notebook ref
            notebooks.removeAll(where: { $0 == notebook })
            // delete object
            notebooks.removeAll(where: { $0.id == notebook.id })
        }
        // add to deleted list
        deletedNotebooks.insert(notebook, at: 0)
        // save restore path
        deletedNotebookRestorePaths[notebook.id.uuidString] = notebook.path
        
//        // reconstruct list
//        let deletedNotesList = NotebooksHierarchy.constructHierarchy(notebooks: deletedNotebooks, expandedIds: expandedIds)
//        deletedNotes = deletedNotesList
        
        // persist
        notebookBusiness.persist(notebooks: notebooks)
//        notebookBusiness.persistDeleted(notebooks: deletedNotebooks)
//        notebookBusiness.persistDeletedRestorePath(notebooks: deletedNotebookRestorePaths)
    }
    
    
    func rename(for notebook: Notebook, newValue: String) throws {
        // validate characters
        if newValue.contains(":") {
            throw NotebookBusinessError.invalidCharacters
        }
        // check if already same file name exists
        if let parent = notebook.parent {
            if isAlreadyExists(fileName: newValue, in: parent.children!) {
                throw NotebookBusinessError.alreadyExists
            }
        } else {
            if isAlreadyExists(fileName: newValue, in: notebooks) {
                throw NotebookBusinessError.alreadyExists
            }
        }
        // store name
        notebook.name = newValue
        // persist changes
        notebookBusiness.persist(notebooks: notebooks)
    }
    
//    func move(notebooksM: inout [NotebookM], from source: IndexSet, to destination: Int) {
//        // move references
//        if notebooksM.first?.notebookRef.parent?.children != nil {
//            notebooksM.first?.notebookRef.parent?.children.move(fromOffsets: source, toOffset: destination)
//        } else {
//            self.notebooks.move(fromOffsets: source, toOffset: destination)
//        }
//        // move structs
//        notebooksM.move(fromOffsets: source, toOffset: destination)
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
        
//        $searchText
//            .map({ (string) -> String? in
//                if string.count < 2 {
////                    self.usersDB.notes = []
//                    self.searchResultCount = 0
//                    return nil
//                }
//                return string
//            })
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .receive(on: RunLoop.main)
//            .compactMap{ $0 }
//            .sink { status in
////                print(status)
//            } receiveValue: { [self] (searchField) in
//                searchItems(searchField)
//            }.store(in: &subscription)
    }
    
    var activeSearch: Bool {
        (isSearching && searchText.count > 1) || isShowingRecent
    }
    
    func searchItems(_ text: String) {
        
        if isSearching == false {
            return
        }
        
        if text.count == 0 {
//            notesHierarchy.notes = backupNotebooks
            searchResultCount = 0
        } else {
            //            usersDB.notes = backupNotebooks.filter { note in
            //                return note.name.lowercased().contains(text.lowercased())
            //            }
            
            var resultsCount = 0
            
//            func canAddNotebook(note: inout NotebookM) -> Bool {
//                
//                // go deep first, if deep return true, then mark current as true
//                // if deep is false, then check current name condition
//                
//                // check nested items
//                var childStatus = Set<Bool>()
//                if note.children != nil {
//                    let count = note.children!.count
//                    for i in 0..<count {
//                        let canAdd = canAddNotebook(note: &note.children![i])
//                        childStatus.insert(canAdd)
//                    }
//                }
//                if childStatus.contains(true) {
//                    note.canShow = false
//                    note.isExpanded = true
//                } else {
//                    if note.name.lowercased().contains(text.lowercased()) {
//                        note.canShow = true
//                        note.isExpanded = true
//                        
//                        resultsCount += 1
//                    } else {
//                        note.canShow = false
//                        note.isExpanded = false
//                    }
//                }
//                
//                if note.isExpanded {
//                    return true
//                }
//                
//                return note.canShow
//            }
            
//            var notebooksList = notebooks
////            var expandedIds = Set<String>()
//            
//            for i in 0..<notebooksList.count {
//                _ = canAddNotebook(note: &notebooksList[i])
////                print("checked \(i)")
//            }
////            print("NEW LIST")
//            notesHierarchy.notes = notebooksList
//            searchResultCount = resultsCount
        }
    }
    
    
}

// MARK: - recent notebooks list
extension NotebooksListState {
    
    var recentButtonIcon: String {
        isShowingRecent ? "clock.fill" : "clock"
    }
    
    func showHideRecentlyModified() {
        if isShowingRecent {
            hideRecentlyModified()
        } else {
            showRecentlyModified()
        }
    }
    
    func hideRecentlyModified() {
        isShowingRecent = false
    }
    
    func showRecentlyModified() {
        
        let recentItems = recentNotebooks.items
        
        var resultsCount = 0
        
//        func canAddNotebook(note: inout NotebookM) -> Bool {
//            
//            // go deep first, if deep return true, then mark current as true
//            // if deep is false, then check current name condition
//            
//            // check nested items
//            var childStatus = Set<Bool>()
//            if note.children != nil {
//                let count = note.children!.count
//                for i in 0..<count {
//                    let canAdd = canAddNotebook(note: &note.children![i])
//                    childStatus.insert(canAdd)
//                }
//            }
//            if childStatus.contains(true) {
//                note.canShow = false
//                note.isExpanded = true
//            } else {
//                if recentItems.contains(note.id.uuidString) {
//                    note.canShow = true
//                    note.isExpanded = true
//                    
//                    resultsCount += 1
//                } else {
//                    note.canShow = false
//                    note.isExpanded = false
//                }
//            }
//            
//            if note.isExpanded {
//                return true
//            }
//            
//            return note.canShow
//        }
        
//        var notebooksList = notesHierarchy.notes
////            var expandedIds = Set<String>()
//        
//        for i in 0..<notebooksList.count {
//            _ = canAddNotebook(note: &notebooksList[i])
////                print("checked \(i)")
//        }
////            print("NEW LIST")
//        notesHierarchy.notes = notebooksList
//        searchResultCount = resultsCount
//        
//        isShowingRecent = true
    }
}

// MARK: Deleted Notebooks

extension NotebooksListState {
    
    func restore(notebook:  Notebook, in notebooks: inout [Notebook], at path: [String], sibling: String?) {
        // if parent is not nil, reach its root parent, then restore this parent.
        // get parent ref to insert
        
        if path.count == 0 && sibling != nil {
            // base level
            guard let siblingIndex = notebooks.firstIndex(where: { $0.id.uuidString == sibling! }) else { return }
            notebooks.insert(notebook, at: siblingIndex + 1)
        }
        
        
        var ref: Notebook
        guard let baseRef = notebooks.first(where: { $0.id.uuidString == path[0] }) else { return }
        ref = baseRef
        
        if path.count >= 2 {
            for i in 1..<path.count {
                let id = path[i]
                guard let baseRef = ref.children?.first(where: { $0.id.uuidString == path[0] }) else { return }
                ref = baseRef
            }
        }
        
        if let sibling = sibling {
            let siblingIndex = ref
        }
        
    }
}
