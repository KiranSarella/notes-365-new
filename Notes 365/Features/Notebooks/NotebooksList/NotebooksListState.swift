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
    
    let notebookBusiness = NotebooksListBusiness(EnvironmentState.shared.basePathURL)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    var notebooks = [Notebook]()
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
    
    var presentDeleteConfirmation = false
    var deletingNotebook: Notebook? = nil
    
    private var backupNotebooks = [Notebook]()
    private var backupExpandedIds = Set<String>()
    
    let notebooksPath = Constants.notebooksFolderName
    
    var selectedNotebook: Notebook? = nil
    
    var canEnableDone: Bool {
        listSourceType == .deletedItems || listSourceType == .notebooks(.recentlyModified)
    }
    
    var firstTimeAppear = true
    
    var timelineCreatorBusiness = TimelineBusiness(path: EnvironmentState.shared.basePathURL)
    
    init() {
        timelineCreatorBusiness.registerNotebookChangesNotification()
        
        isLoading = true
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        // create notesHierarchy with actual notebook objects
//        notebooks = notebookBusiness.retrieveNotebooks() ?? []
//        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
//        notesHierarchy = NotebooksHierarchy(notes: notesList)
        
        // construct deleted notebooks list
//        deletedNotebooks = notebookBusiness.retrieveDeletedNotebooks() ?? []
//        checkOldItemsToDelete()
        
        // observe after initial hierarcy is constructed
        NotificationCenter.default.addObserver(self, selector: #selector(listenExpandCollapseNotification(_:)), name: .ExpandCollapseNotification, object: nil)
        
        setupSearchText()
        
        registerNotebookChangesNotification()
        isLoading = false
        
        
    }
    
    deinit {
        timelineCreatorBusiness.removeNotebookChangesNotification()
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
//        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
//        notesHierarchy = NotebooksHierarchy(notes: notesList)
    }

    func reloadNotebooksListIfNewRequired() {
        // if notebooks list is empty, try to reload on demand
        if notebookBusiness.isReloadRequired() {
            isLoading = true
            // create notesHierarchy with actual notebook objects
            guard let list = notebookBusiness.retrieveNotebooks() else {
                isLoading = false
                return
            }
            // clear
//            notesHierarchy.notes.removeAll()
            // update
            notebooks = list
//            let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
//            notesHierarchy = NotebooksHierarchy(notes: notesList)
            isLoading = false
        }
    }
    
    func forceReload() {
        isLoading = true
        // clear
//        notesHierarchy.notes.removeAll()
        // create notesHierarchy with actual notebook objects
//        notebooks = notebookBusiness.retrieveNotebooks() ?? []
//        // construct deleted notebooks list
//        deletedNotebooks = notebookBusiness.retrieveDeletedNotebooks() ?? []
//        
        // reconstruct hierarchy
//        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
//        notesHierarchy = NotebooksHierarchy(notes: notesList)
        
        switch listSourceType {
        case .notebooks(let notebooksFilterType):
            switch notebooksFilterType {
            case .none:
                break
            case .searching:
                // ??
                break
            case .recentlyModified:
                showRecentlyModified()
            }
        case .deletedItems:
            showRecentlyDeleted()
            checkOldItemsToDelete()
        }
        
        
        isLoading = false
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
        
        guard let modelContext = modelContext else { return }
        
        withAnimation {
            let notebook = generateNotebook(parent: nil)
            notebook.orderID = 0
            notebooks = [notebook]
            notebook.saveNotebookData(modelContext)
//            modelContext?.insert(notebook)
            
        }
//        fetchNotebooks()
        
//        // create file
//        notebookBusiness.addFirst(notebook: notebook)
//        // add to heirarchy
//        notebooks.append(notebook)
//        // persist hierarchy
//        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func insertBelow(ref notebook: Notebook) {
        
        guard let modelContext = modelContext else { return }
        
        let newNotebook = generateNotebook(parent: notebook.parent)
        
        if notebook.parent != nil {
            // set parent
            newNotebook.parent = notebook.parent
            
            if notebook.parent!.children != nil {
                // if children contains
//                notebook.parent?.children?.append(newNotebook)
                
                // get index of current notebook
//                let sortedArr = sortedChildren.sorted { $0.orderID < $1.orderID }
//                notebook.parent!.onlySelfSortChildren()
                guard let index = notebook.parent!.children!.firstIndex(of: notebook) else { return }
                let insertIndex = index + 1
                print("insertIndex: ", insertIndex)
                
//                // order number
                newNotebook.orderID = insertIndex
                // save
//                modelContext.insert(newNotebook)
//                notebook.parent!.onlySelfSortChildren()
                // insert to hierachy create object
                notebook.parent!.children!.insert(newNotebook, at: insertIndex)
                newNotebook.saveNotebookData(modelContext)
                
//                sortedChildren.insert(newNotebook, at: index + 1) // not working
                
//                let start = index + 2
//                for i in start..<sortedChildren.count {
//                    sortedChildren[i].name = "\(i) " + Faker().name.name()
//                    sortedChildren[i].orderID = i
////                    children[i].orderID = i
//                }
//                
//                notebook.parent!.children = sortedChildren
//                
//                // print order ids
//                for i in 0..<sortedChildren.count {
//                    print(sortedChildren[i].orderID, sortedChildren[i].name)
//                }
                
//                notebook.parent?.onlySelfSortChildren()
                // update order number to rest of the notebooks
                let start = insertIndex + 1
                if start < notebook.parent!.children!.count {
                    for i in start..<notebook.parent!.children!.count {
    //                    notebook.parent!.children![i].name = "\(i) " + notebook.parent!.children![i].name
                        notebook.parent!.children![i].orderID = i
                    }
                    // print order ids
                    for i in 0..<notebook.parent!.children!.count {
                        print(notebook.parent!.children![i].orderID, notebook.parent!.children![i].name)
                    }
                }
                
                
//                notebook.parent?.onlySelfSortChildren()
                
            } else {
                notebook.parent?.children = [newNotebook]
            }
            // update parent as its childen udpated
            notebook.parent!.updateNotebookData(modelContext)
            
        } else {
            // no parent, so root objects
            // get index of current notebook
            let index = notebooks.firstIndex(of: notebook)!
            // order number
//            newNotebook.name = "\(index + 1) " + newNotebook.name
            newNotebook.orderID = index + 1
            // insert to hierachy create object
            notebooks.insert(newNotebook, at: index + 1)
            newNotebook.saveNotebookData(modelContext)
            // update order number to rest of the notebooks
//            let start = index + 2
            for i in 0..<notebooks.count {
//                notebooks[i].name = "\(i) " + newNotebook.name
                notebooks[i].orderID = i
            }
            // print order ids
            for notebook in notebooks {
                print(notebook.orderID, notebook.name)
            }
        }
//        
//        if notebook.parent != nil {
//            
//            
//            
//            if notebook.parent?.children == nil {
//                
//                
//            } else {
//                
//            }
//            
//            
//            
//        } else {
//            
//        }
//        
        
//        notebooks.append(newNotebook)
//        try? modelContext.save()
//        modelContext.insert(newNotebook)
        
//        // create actual notebook
//        let (childNotebook, parent, index) = insertBelow(notebook: notebook)
//        // persist
//        notebookBusiness.persist(notebooks: notebooks)
    }
    

    
    func insertInside(ref notebook: Notebook) {
        
        guard let modelContext = modelContext else { return }
        
        let newNotebook = generateNotebook(parent: notebook)
        newNotebook.parent = notebook
        
        if notebook.children == nil {
            notebook.children = [newNotebook]
        } else {
            notebook.children?.append(newNotebook)
        }
        
        newNotebook.saveNotebookData(modelContext)
        notebook.updateNotebookData(modelContext)
        
//        try? modelContext?.save()
        
//        // create actual notebook in the storage and hierarchy
//        let childNotebook = insertInside(notebook: notebook)
//        // persist
//        notebookBusiness.persist(notebooks: notebooks)
    }
    
//    private func insertInside(notebook: Notebook, below index: Int? = nil) -> Notebook {
//        let fullPath = notebooksPath
//        let newNotebook = generateNotebook(parent: notebook)
//        
//        //        let newNotebook = createNotebook(atPath: fullPath)
//        newNotebook.parent = notebook
//        
//        if let index = index {
//            // create object
//            notebook.children!.insert(newNotebook, at: index + 1)
//            // ..folder already exists
//        } else if notebook.children == nil {
//            // create object
//            notebook.children = [newNotebook]
//            // create folder
//            //            dataManager.createFolder(fullPath)
//        } else {
//            // create object
//            notebook.children?.append(newNotebook)
//            // ..folder already exists
//        }
//        // create phycical file
//        notebookBusiness.insertInside(notebook: newNotebook)
//        return newNotebook
//    }
    
    func generateNotebook(parent: Notebook?) -> Notebook {
        
        // generate non existed file name at that level
        var fileName = ""
        if let parent = parent {
            fileName = generateFileName(at: parent.children)
        } else {
            fileName = generateFileName(at: notebooks)
        }
        
        let newNotebook = Notebook(id: UUID(), name: fileName)
        // store reference
        NotebooksCache.shared.store(notebook: newNotebook)
        
        return newNotebook
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
//        deletedNotebookRestorePaths[notebook.id.uuidString] = notebook.path
        
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
        
//        // persist changes
//        notebookBusiness.persist(notebooks: notebooks)
    }

    func updateModifiedDate(for notebook: Notebook) {
        notebook.modifiedDate = Date()
        // persist changes
        notebookBusiness.persist(notebooks: notebooks)
    }
    
    func move(notebooks: inout [Notebook], from source: IndexSet, to destination: Int) {
        // move references
        if notebooks.first?.parent?.children != nil {
            notebooks.first?.parent?.children?.move(fromOffsets: source, toOffset: destination)
        } else {
            self.notebooks.move(fromOffsets: source, toOffset: destination)
        }
        // move structs
        notebooks.move(fromOffsets: source, toOffset: destination)
        
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
            if note.children != nil {
                let count = note.children!.count
                for i in 0..<count {
                    let anyVisibleChildren = canAddNotebook(note: &note.children![i])
                    visibleChildsStatus.insert(anyVisibleChildren)
                }
            }
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
    
    
    func registerNotebookChangesNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeNotebookChangesNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
//        print(#function)
        guard
            let uuid = notification.userInfo?["id"] as? String,
            let notebook = selectedNotebook
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
//        notesHierarchy.notes = backupNotebooks
        
        backupNotebooks = [Notebook]()
        backupExpandedIds = []
        
        listSourceType = .notebooks(.none)
    }
    
    func showRecentlyDeleted() {
        // backup normal hierarchy state
        backupExpandedIds = expandedIds
        backupNotebooks = notebooks
        
//        let deletednotesList = NotebooksHierarchy.constructHierarchy(notebooks: deletedNotebooks, expandedIds: [])
//        notesHierarchy.notes = deletednotesList
        
//        deletedResultCount = deletednotesList.count
        
        listSourceType = .deletedItems
    }
    
    func checkOldItemsToDelete() {
        
        // delete date exceeded notebooks
        notebookBusiness.deleteDateExceededNotebooks(deletedNotebooks: &deletedNotebooks)
    }
    
}
