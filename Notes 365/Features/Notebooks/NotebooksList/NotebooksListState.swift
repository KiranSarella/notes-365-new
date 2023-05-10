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


class NotebooksListState: ObservableObject {
    
    static let shared: NotebooksListState = NotebooksListState()
    
    let notebookBusiness = NotebooksListBusiness(EnvironmentState.shared.basePathURL)
    
    var subscription: Set<AnyCancellable> = []
    var expandedIds = Set<String>()
    
    private var notebooks = [Notebook]()
    @Published var notesHierarchy: NotebooksHierarchy
    
    @Published var searchText: String = ""
    @Published var isSearching = false
    
    @Published var presentDeleteConfirmation = false
    @Published var deletingNotebook: NotebookM?
    
    private var backupNotebooks = [NotebookM]()
    private var backupExpandedIds = Set<String>()
    
    let notebooksPath = Constants.notebooksFolderName
    
//    @Published var isLoaded = false
    
    init() {
        // get saved expandedIds
        if let expandedList = UserDefaults.standard.object(forKey: "notes365.expandedIds") as? [String] {
            expandedIds = Set(expandedList)
        }
        
        // create notesHierarchy with actual notebook objects
        notebooks = notebookBusiness.retrieveNotebooks() ?? []
        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: expandedIds)
        notesHierarchy = NotebooksHierarchy(notes: notesList)
        
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
    
//    func deleteNotebook(ref notebook: Notebook) {
//
//        notebookBusiness.deleteNotebook(ref: notebook)
//
//        if let parent = notebook.parent {
//            // delete in hierachy
//            getNotebookReferenceForPath(uuidPath: parent.uuidPath) { noteM in
//                noteM.children!.removeAll(where: { $0.id == notebook.id })
//            }
//        } else {
//            // base level
//            // delete object
//            notesHierarchy.notes.removeAll(where: { $0.id == notebook.id })
//        }
//    }
    
    
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
    
    func takeBackup() {
//        print(#function)
        backupNotebooks = notesHierarchy.notes
        backupExpandedIds = expandedIds
    }
    
    func restoreBackup() {
//        print(#function)
        // restore
        notesHierarchy.notes = backupNotebooks
        expandedIds = backupExpandedIds
        // clean
        backupNotebooks.removeAll()
        backupExpandedIds.removeAll()
    }
    
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
        //            .map({ (string) -> String? in
        //                if string.count < 2 {
        //                    self.usersDB.notes = []
        //                    return nil
        //                }
        //                return string
        //            })
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .compactMap{ $0 }
            .sink { status in
//                print(status)
            } receiveValue: { [self] (searchField) in
                searchItems(searchField)
            }.store(in: &subscription)
    }
    
    
    
    func searchItems(_ text: String) {
        
        if isSearching == false {
            return
        }
        
        if text.count == 0 || text.count == 0 {
            notesHierarchy.notes = backupNotebooks
        } else {
            //            usersDB.notes = backupNotebooks.filter { note in
            //                return note.name.lowercased().contains(text.lowercased())
            //            }
            
            func canAddNotebook(note: inout NotebookM) -> Bool {
                
                // go deep first, if deep return true, then mark current as true
                // if deep is false, then check current name condition
                
                // check nested items
                var childStatus = Set<Bool>()
                if note.children != nil {
                    let count = note.children!.count
                    for i in 0..<count {
                        let canAdd = canAddNotebook(note: &note.children![i])
                        childStatus.insert(canAdd)
                    }
                }
                if childStatus.contains(true) {
                    note.canShow = true
                    note.isExpanded = true
                } else {
                    if note.name.lowercased().contains(text.lowercased()) {
                        note.canShow = true
                        note.isExpanded = true
                    } else {
                        note.canShow = false
                    }
                }
                return note.canShow
            }
            
            var notebooksList = notesHierarchy.notes
//            var expandedIds = Set<String>()
            
            for i in 0..<notebooksList.count {
                _ = canAddNotebook(note: &notebooksList[i])
//                print("checked \(i)")
            }
//            print("NEW LIST")
            notesHierarchy.notes = notebooksList
        }
        
        
    }
    
    
}
