//
//  UsersState.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import Foundation
import SwiftUI
import Combine

/// because Publisher will not triggering change events with array (that too nested array in this case), we moved array to a struct.
struct NotebooksHierarchy {
    
    var notes: [NotebookM]
    
    static func constructHierarchy(notebooks: [Notebook], expandedIds: Set<String>) -> [NotebookM] {
//        print(#function)
        var noteList = [NotebookM]()
        
        for notebook in notebooks {
            /*
             - create notebookM
             - need its children?
                - create children? - just children; not its inner children again
             - after creating its children in a loop
             - assign those to chilren[]
             */
            // - create notebookM
            var note = NotebookM(notebook: notebook)
            note.isExpanded = expandedIds.contains(note.id.uuidString)
            
            if let children = notebook.children {
                note.children = constructHierarchy(notebooks: children, expandedIds: expandedIds)
            }
            
            noteList.append(note)
        }
        
        return noteList
    }
    
}


enum ListState {
    case all
    case recent
    case search
}

extension  Notification.Name {
    public static let ExpandCollapseNotification = Notification.Name("com.notes365.ExpandCollapseNotification")
}

struct NotebookM: Identifiable {
    
    var id: UUID
    var name: String {
        didSet {
            notebookRef.name = self.name
        }
    }
    var children: [NotebookM]? = nil
    var content: String = ""
    var isExpanded: Bool = false {
        didSet {
            let info = ["id": id, "isExpanded": isExpanded] as [String : Any]
            NotificationCenter.default.post(name: .ExpandCollapseNotification, object: nil, userInfo: info)
        }
    }
    
    private(set) var notebookRef: Notebook
    
    init(notebook: Notebook) {
        self.id = notebook.id
        self.name = notebook.name
        self.notebookRef = notebook
    }

    var containChildNotebooks: Bool {
        
        var result: Bool = false
        
        if self.children == nil || self.children?.count == 0 {
            result =  false
        } else {
            result = true
        }
        
        return result
    }
    
    var canShow = true
}

extension NotebookM: Equatable, Hashable {
    
    static func == (lhs: NotebookM, rhs: NotebookM) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
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

class NotebooksListState: ObservableObject {
    
    static let shared: NotebooksListState = NotebooksListState()
    
    let notebookBusiness = NotebooksListBusiness(EnvironmentState.shared.basePathURL)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    private var notebooks = [Notebook]()
    private var deletedNotebooks = [Notebook]()
    
    @Published var notesHierarchy: NotebooksHierarchy
    
    @Published var listSourceType = ListSourceType.notebooks(.none)
    
    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published var searchResultCount: Int = 0
    
//    @Published var isShowingRecent = false
    @Published var modifiedResultCount: Int = 0
    
//    @Published var isShowingRecentlyDeleted = false
    @Published var deletedResultCount: Int = 0
    
    @Published var presentDeleteConfirmation = false
    @Published var deletingNotebook: NotebookM?
    
    private var backupNotebooks = [NotebookM]()
    private var backupExpandedIds = Set<String>()
    
    let notebooksPath = Constants.notebooksFolderName
    
    var selectedNotebook: NotebookM?
    
    var canEnableDone: Bool {
        listSourceType == .deletedItems || listSourceType == .notebooks(.recentlyModified)
    }
    
    var firstTimeAppear = true
    
    init() {
        
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        sleep(10)
        // create notesHierarchy with actual notebook objects
        notebooks = notebookBusiness.retrieveNotebooks() ?? []
        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
        notesHierarchy = NotebooksHierarchy(notes: notesList)
        
        // construct deleted notebooks list
        deletedNotebooks = notebookBusiness.retrieveDeletedNotebooks() ?? []
        checkOldItemsToDelete()
        
        // observe after initial hierarcy is constructed
        NotificationCenter.default.addObserver(self, selector: #selector(listenExpandCollapseNotification(_:)), name: .ExpandCollapseNotification, object: nil)
        
        setupSearchText()
        
        registerNotebookChangesNotification()
    }
    
    deinit {
        removeNotebookChangesNotification()
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
        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
        notesHierarchy = NotebooksHierarchy(notes: notesList)
    }

    func reloadNotebooksList() {
        // if notebooks is empty, try to reload on demand
        if notebooks.count == 0 || notebookBusiness.isReloadRequired() {
            // clear
            notesHierarchy.notes.removeAll()
            // create notesHierarchy with actual notebook objects
            notebooks = notebookBusiness.retrieveNotebooks() ?? []
            let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
            notesHierarchy = NotebooksHierarchy(notes: notesList)
        }
    }
    
    func forceReload() {
        // clear
        notesHierarchy.notes.removeAll()
        // create notesHierarchy with actual notebook objects
        notebooks = notebookBusiness.retrieveNotebooks() ?? []
        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
        notesHierarchy = NotebooksHierarchy(notes: notesList)
    }
    
    func saveExpandedIds() {
        UserDefaults.standard.set(Array(expandedIds), forKey: "notes365.expandedIds")
    }
    
    
//    func fetchExpandedIds() {
//        expandedIds = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? Set<UUID> ?? Set<UUID>()
//    }
    
    var isEmpty: Bool {
        notesHierarchy.notes.count == 0
    }
    
    func addFirstNotes() {
        let notebook = createNotebook(parent: nil)
        // create file
        notebookBusiness.addFirst(notebook: notebook)
        // add to heirarchy
        notebooks.append(notebook)
        notesHierarchy.notes.append(NotebookM(notebook: notebook))
        // persist hierarchy
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func insertBelow(ref notebook: Notebook) {
        // create actual notebook
        let (childNotebook, parent, index) = insertBelow(notebook: notebook)
        // create state notebook object
        let notebookM = NotebookM(notebook: childNotebook)
        // insert in hierachy
        if parent == nil {
            // insert at base level
            notesHierarchy.notes.insert(notebookM, at: index + 1)
        } else {
            getNotebookReferenceForPath(uuidPath: parent!.uuidPath) { noteM in
                noteM.children!.insert(notebookM, at: index + 1)
            }
        }
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
        // create state notebook object
        let notebookM = NotebookM(notebook: childNotebook)
        // insert in hierachy
        getNotebookReferenceForPath(uuidPath: notebook.uuidPath) { noteM in
            if noteM.children == nil {
                noteM.children = [notebookM]
            } else {
                noteM.children!.append(notebookM)
            }
        }
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
            notebook.children?.insert(newNotebook, at: index + 1)
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
            parent.children!.removeAll(where: { $0 == notebook })
            // delete in hierachy
            getNotebookReferenceForPath(uuidPath: parent.uuidPath) { noteM in
                noteM.children!.removeAll(where: { $0.id == notebook.id })
            }
        } else {
            // base level
            // delete notebook ref
            notebooks.removeAll(where: { $0 == notebook })
            // delete object
            notesHierarchy.notes.removeAll(where: { $0.id == notebook.id })
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
            parent.children!.removeAll(where: { $0 == notebook })
            // delete in hierachy
            getNotebookReferenceForPath(uuidPath: parent.uuidPath) { noteM in
                noteM.children!.removeAll(where: { $0.id == notebook.id })
            }
        } else {
            // base level
            // delete notebook ref
            notebooks.removeAll(where: { $0 == notebook })
            // delete object
            notesHierarchy.notes.removeAll(where: { $0.id == notebook.id })
        }
        // add to deleted list
        notebook.deletedDate = Date()
        deletedNotebooks.insert(notebook, at: 0)
        
//        // reconstruct list
//        let deletedNotesList = NotebooksHierarchy.constructHierarchy(notebooks: deletedNotebooks, expandedIds: expandedIds)
//        notesHierarchy.deletedNotes = deletedNotesList
        
        // persist
        notebookBusiness.persist(notebooks: notebooks)
        notebookBusiness.persistDeleted(notebooks: deletedNotebooks)
    }
    
    
    func rename(for notebook: Notebook, newValue: String) throws {
        // validate characters
        if newValue.contains(":") {
            throw NotebookBusinessError.invalidCharacters
        }
        // check if already same file name exists
        if let parent = notebook.parent {
            if let children = parent.children {
                if isAlreadyExists(fileName: newValue, in: children) {
                    throw NotebookBusinessError.alreadyExists
                }
            }
        } else {
            if isAlreadyExists(fileName: newValue, in: notebooks) {
                throw NotebookBusinessError.alreadyExists
            }
        }
        // store name
        notebook.name = newValue
        // update model
        getNotebookReferenceForPath(uuidPath: notebook.uuidPath) { noteM in
            noteM.name = newValue
        }
        // persist changes
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func updateModifiedDate(for notebook: Notebook) {
        notebook.modifiedDate = Date()
        // persist changes
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func move(notebooksM: inout [NotebookM], from source: IndexSet, to destination: Int) {
        // move references
        if notebooksM.first?.notebookRef.parent?.children != nil {
            notebooksM.first?.notebookRef.parent?.children?.move(fromOffsets: source, toOffset: destination)
        } else {
            self.notebooks.move(fromOffsets: source, toOffset: destination)
        }
        // move structs
        notebooksM.move(fromOffsets: source, toOffset: destination)
        
        // persist refernce list
        notebookBusiness.persist(notebooks: self.notebooks)
    }
    
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
    
    func getNotebookReferenceForPath(uuidPath: [UUID], completion: ((inout NotebookM) -> ())) {
        
        if uuidPath.count == 0 {
            // top level
            let index = notesHierarchy.notes.firstIndex(where: { $0.id == uuidPath.first! })!
            completion(&notesHierarchy.notes[index])
        } else {
            
            var uuids = uuidPath
            var index = notesHierarchy.notes.firstIndex(where: { $0.id == uuids.first! })!
            uuids.removeFirst()
            // get selected Notebook reference (bcz we are using struct, we need use assignment)
            func getSelectedNotebookReference(notebook: inout NotebookM) {
                // base condition
                if uuids.count <= 0 {
                    completion(&notebook)
                    return
                }
                // next level
                index = notebook.children!.firstIndex(where: { $0.id == uuids.first! })!
                uuids.removeFirst()
                // next element
                getSelectedNotebookReference(notebook: &notebook.children![index])
            }
            // start resurssion
            getSelectedNotebookReference(notebook: &notesHierarchy.notes[index])
        }
    }
    
    
    func getNotebookReference(levels selectedLevels: [Int], index selectedIndex: Int,
                              completion: ((inout NotebookM) -> ())) {
        
        if selectedLevels.isEmpty {
            // top level
            completion(&notesHierarchy.notes[selectedIndex])
        } else {
            
            var levels = selectedLevels
            levels.append(selectedIndex) // because selectedIndex is the last level
            
            var baseLevel = levels.first!
            
            levels.removeFirst() // remove base level
            
            // get selected Notebook reference (bcz we are using struct, we need use assignment)
            func getSelectedNotebookReference(notebook: inout NotebookM) {
                
                // base condition
                if levels.count <= 0 {
                    completion(&notebook)
                    return
                }
                
                // next level
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: &notebook.children![baseLevel])
            }
            getSelectedNotebookReference(notebook: &notesHierarchy.notes[baseLevel])
        }
    }
    
    func getNotebook(levels: [Int], index: Int) -> NotebookM? {
        
        var notebooks = notesHierarchy.notes
        
        for level in levels {
            
            if notebooks[level].children != nil {
                notebooks = notebooks[level].children!
            }
        }
        
        if notebooks.indices.contains(index) {
            return notebooks[index]
        } else {
            return nil
        }
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
        
        $searchText
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
            
            func canAddNotebook(note: inout NotebookM) -> Bool {
                
                // for expansion: isExpanded
                // go deep first, if deep return true, then mark current as true
                // if deep is false, then check current name condition
                
                // for canShow:
                // if name contains search str - true else false
                
                
                // check nested items
                var visibleChildsStatus = Set<Bool>()
                // if children exists
                if note.children != nil {
                    let count = note.children!.count
                    for i in 0..<count {
                        let anyVisibleChildren = canAddNotebook(note: &note.children![i])
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
            
            var notebooksList = notesHierarchy.notes
            
            for i in 0..<notebooksList.count {
                _ = canAddNotebook(note: &notebooksList[i])
            }
            // update
            notesHierarchy.notes = notebooksList
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
        
        func canAddNotebook(note: inout NotebookM) -> Bool {
            
            // for expansion: isExpanded
            // go deep first, if deep return true, then mark current as true
            // if deep is false, then check current name condition
            
            // for canShow:
            // if name contains search str - true else false
            
            
            // check nested items
            var visibleChildsStatus = Set<Bool>()
            // if children exists
            if note.children != nil {
                let count = note.children!.count
                for i in 0..<count {
                    let anyVisibleChildren = canAddNotebook(note: &note.children![i])
                    visibleChildsStatus.insert(anyVisibleChildren)
                }
            }
            // check if search str contains in file name
            if note.notebookRef.modifiedDate >= Calendar.current.date(byAdding: .day, value: -1, to: Date())! {
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
        
        var notebooksList = notesHierarchy.notes
        
        for i in 0..<notebooksList.count {
            _ = canAddNotebook(note: &notebooksList[i])
        }

        notesHierarchy.notes = notebooksList
        modifiedResultCount = resultsCount
        
        listSourceType = .notebooks(.recentlyModified)
    }
    
    
    func registerNotebookChangesNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeNotebookChangesNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        print(#function)
        guard
            let uuid = notification.userInfo?["id"] as? String,
            let notebook = selectedNotebook?.notebookRef
        else { return }
        
        if notebook.id.uuidString == uuid {
            updateModifiedDate(for: notebook)
        }
    }
}

// MARK: - recently deleted
extension NotebooksListState {
    
    var recentlyDeletedButtonIcon: String {
//        isShowingRecentlyDeleted ? "trash.fill" : "trash.square"
        listSourceType == .deletedItems ? "trash" : "trash"
    }
    
    
//    func showHideRecentlyDeleted() {
//
//        if listSourceType == .deletedItems {
//            hideRecentlyDeleted()
//        } else {
//            showRecentlyDeleted()
//        }
//    }
    
    func hideRecentlyDeleted() {
        
        expandedIds = backupExpandedIds
        notesHierarchy.notes = backupNotebooks
        
        backupNotebooks = [NotebookM]()
        backupExpandedIds = []
        
        listSourceType = .notebooks(.none)
    }
    
    func showRecentlyDeleted() {
        // backup normal hierarchy state
        backupExpandedIds = expandedIds
        backupNotebooks = notesHierarchy.notes
        
        let deletednotesList = NotebooksHierarchy.constructHierarchy(notebooks: deletedNotebooks, expandedIds: [])
        notesHierarchy.notes = deletednotesList
        
        deletedResultCount = deletednotesList.count
        
        listSourceType = .deletedItems
    }
    
    func checkOldItemsToDelete() {
        
        // delete date exceeded notebooks
        notebookBusiness.deleteDateExceededNotebooks(deletedNotebooks: &deletedNotebooks)
    }
    
}
