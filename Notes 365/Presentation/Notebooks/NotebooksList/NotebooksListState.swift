//
//  UsersState.swift
//  ListExample
//
//  Created by Kiran Sarella on 23/11/21.
//

import Foundation
import SwiftUI

/// because Publisher will not triggering change events with array (that too nested array in this case), we moved array to a struct.
struct NotebooksHierarchy {
    
    var notes: [NotebookM]
    
    static func constructHierarchy(notebooks: [Notebook]) -> [NotebookM] {
        
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
            
            if let children = notebook.children {
                note.children = constructHierarchy(notebooks: children)
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

struct NotebookM: Identifiable {
    
    var id: UUID
    var name: String {
        didSet {
            notebook.name = self.name
        }
    }
    var children: [NotebookM]? = nil
    var content: String = ""
    var isExpanded: Bool = false
    
    private(set) var notebook: Notebook
    
    init(notebook: Notebook) {
        self.id = notebook.id
        self.name = notebook.name
        self.notebook = notebook
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
    
    let notebookBusiness = NotebooksListBusiness.shared
    
    @Published var usersDB: NotebooksHierarchy
    
    var userSelectionStateTwo: SelectedNotebookInfo?
    
    var isNotebooksLimitExceeded: Bool {
        
        return notebookBusiness.isNotebooksLimitExceeded()
    }
    
  
    init() {
        // create notesHierarchy with actual notebook objects
        let notebooks = notebookBusiness.getNotebooks()
        let notesList = NotebooksHierarchy.constructHierarchy(notebooks: notebooks)
        usersDB = NotebooksHierarchy(notes: notesList)
    }

    func canAddNotebook() -> Bool {
#if DEBUG
        return true
#endif
        if isSubscribed {
            return true
        } else {
            return isNotebooksLimitExceeded == false
        }
    }
    
    var isSubscribed: Bool {
        return PurchasesBusiness().isSubscribed
    }
    
    func isSelected(userID: UUID) -> Bool {
        guard let selectedUser = self.userSelectionStateTwo?.notebook else { return false }
        
        return selectedUser.id == userID
    }
    
    
    func deleteUser() {
        
        guard let selectedLevels = userSelectionStateTwo?.levels else {
            return
        }
        guard let selectedIndex = userSelectionStateTwo?.index else {
            return
        }
        
        notebookBusiness.deleteNotebook(levels: selectedLevels, index: selectedIndex)
        
        
        if selectedLevels.isEmpty {
            // top level
            // delete object
            usersDB.notes.remove(at: selectedIndex)
        } else {
            
            // remove top level, as we used it.
            var baseLevel = selectedLevels.first!
            var levels = selectedLevels
            levels.removeFirst()
            
            // traverse to inner selected note
            func getSelectedNotebookReference(notebook: inout NotebookM) {
                
                // base condition
                if levels.count <= 0 {
                    
                    // reached to deeper level, so remove element
                    notebook.children?.remove(at: selectedIndex)
                    return
                }
                
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: &notebook.children![baseLevel])
            }
            
            // if selected level is inner level, then pass
            getSelectedNotebookReference(notebook: &usersDB.notes[baseLevel])
        }
    }
    
    
    func addFirstNotes() {
        let notebook = notebookBusiness.addFirstNotes()
        usersDB.notes.append(NotebookM(notebook: notebook))
    }
    
  
    func insertUserBelowSelection() {
        
        guard let selectedLevels = userSelectionStateTwo?.levels else {
            return
        }
        
        guard let selectedIndex = userSelectionStateTwo?.index else {
            return
        }
        
        let notebook = notebookBusiness.insertUserBelowSelection(levels: selectedLevels, index: selectedIndex)
        let notebookM = NotebookM(notebook: notebook)
        
        if selectedLevels.isEmpty {
            // top level
            usersDB.notes.insert(notebookM, at: selectedIndex + 1)
        } else {
            
            var baseLevel = selectedLevels.first!
            var levels = selectedLevels
            levels.removeFirst()
            
            func getSelectedNotebookReference(notebook: inout NotebookM) {
                
                // when referered to last level (ie selected notebook)
                if levels.count <= 0 {
                    
                    // get path for all folders using level numbers
                    
                    let insertIndex = selectedIndex + 1
                    // check index out
                    if let count = notebook.children?.count, count >= insertIndex {
                        notebook.children?.insert(notebookM, at: selectedIndex + 1)
                    } else {
                        notebook.children?.append(notebookM)
                    }
                    
                    return
                }
                
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: &notebook.children![baseLevel])
            }
            
            getSelectedNotebookReference(notebook: &usersDB.notes[baseLevel])
        }
        
        
        
    }
    
    
    func insertInsideSelection() {
        
        guard var selectedLevels = userSelectionStateTwo?.levels else {
            return
        }
        guard let lastLevel = userSelectionStateTwo?.index else {
            return
        }
        
        let notebookRef = notebookBusiness.insertInsideSelection(levels: selectedLevels, index: lastLevel)
        let notebookM = NotebookM(notebook: notebookRef)
        
        if selectedLevels.isEmpty {
            // top level
            let selectedNotebook = usersDB.notes[lastLevel]
            
            if selectedNotebook.children == nil {
                
                usersDB.notes[lastLevel].children = [notebookM]
            } else {
                // create object
                usersDB.notes[lastLevel].children?.append(notebookM)
            }
        } else {
            
            selectedLevels.append(lastLevel) // because selectedIndex is the last level
            
            var baseLevel = selectedLevels.first!
            
            var levels = selectedLevels
            levels.removeFirst() // remove base level
            
            // get selected Notebook reference (bcz we are using struct, we need use assignment)
            func getSelectedNotebookReference(notebook: inout NotebookM) {
                
                // base condition
                if levels.count <= 0 {
                    
                    if notebook.children == nil {
                        // create object
                        notebook.children = [notebookM]
                        
                    } else {
                        // create object
                        notebook.children?.append(notebookM)
                    }
                    
                    return
                }
                
                // next level
                baseLevel = levels.first!
                levels.removeFirst()
                
                // next element
                getSelectedNotebookReference(notebook: &notebook.children![baseLevel])
                
            }
            
            getSelectedNotebookReference(notebook: &usersDB.notes[baseLevel])
        }
    }
    
    func insertInside(ref notebook: Notebook) {
        
        let childNotebook = notebookBusiness.insertInside(ref: notebook)
        
        // get path
        getNotebookReferenceForPath(uuidPath: notebook.uuidPath) { noteM in
            if noteM.children == nil {
                // create object
                let notebookM = NotebookM(notebook: childNotebook)
                noteM.children = [notebookM]

            } else {
                // create object
                let notebookM = NotebookM(notebook: childNotebook)
                noteM.children?.append(notebookM)
            }
        }
    }
    
    func renameNotebook(editingFileName: String) throws {
        
        guard let selectedLevels = userSelectionStateTwo?.levels else {
            return
        }
        guard let selectedIndex = userSelectionStateTwo?.index else {
            return
        }
        
        try notebookBusiness.renameNotebook(levels: selectedLevels, index: selectedIndex, editingFileName: editingFileName)
        
        // update model
        getNotebookReference(levels: selectedLevels, index: selectedIndex) { refNotebook in
            refNotebook.name = editingFileName
        }
        
    }
    
    // MARK: -
    
    func getFolderNamesPath(levels: [Int]) -> String {
        notebookBusiness.getFolderNamesPath(levels: levels)
    }
    
    func getNotebookReferenceForPath(uuidPath: [UUID], completion: ((inout NotebookM) -> ())) {
        
        if uuidPath.count == 0 {
            // top level
            let index = usersDB.notes.firstIndex(where: { $0.id == uuidPath.first! })!
            completion(&usersDB.notes[index])
        } else {
            
            var uuids = uuidPath
            var index = usersDB.notes.firstIndex(where: { $0.id == uuids.first! })!
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
            getSelectedNotebookReference(notebook: &usersDB.notes[index])
        }
    }
    
    
    func getNotebookReference(levels selectedLevels: [Int], index selectedIndex: Int,
                              completion: ((inout NotebookM) -> ())) {
        
        if selectedLevels.isEmpty {
            // top level
            completion(&usersDB.notes[selectedIndex])
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
            getSelectedNotebookReference(notebook: &usersDB.notes[baseLevel])
        }
    }
    
    func getNotebook(levels: [Int], index: Int) -> NotebookM? {
        
        var notebooks = usersDB.notes
        
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


