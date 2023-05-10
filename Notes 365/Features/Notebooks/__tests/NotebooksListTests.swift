//
//  NotebooksListTests.swift
//  Notes 365Tests
//
//  Created by Kiran Sarella on 05/04/23.
//

import XCTest

/*
 
 - to add notebooks, 
 
 */


final class NotebooksListTests: XCTestCase {

    var baseURL: URL!
    var notebooksListState: NotebooksListState!

    override func setUpWithError() throws {
        
        // setup test directory environment
        let tempDirUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                  in: .userDomainMask).last!
        
        baseURL = tempDirUrl.appending(component: "documents-test")
        print(baseURL ?? "--")
        
        if FileManager.default.fileExists(atPath: baseURL.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: baseURL)
        }
        
        // path is under XCTestDevices, so using documents folder instead of tmp
        try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: false)
        
        // it will create a singleton environment state with base url
        try ChooseEnvironment().setEnviromment(with: .custom(baseURL))
        
        // create list state
        notebooksListState = NotebooksListState()
//        print("--COUNT--", notebooksListState.notesHierarchy.notes.count)
        
    }

    override func tearDownWithError() throws {
//        notebooksListState.notesHierarchy.notes.removeAll()
        
        notebooksListState = nil
        // clear all contents of directory
        try FileManager.default.removeItem(at: baseURL)
        
    }
    
    // MARK: - Add Notebooks
    func testAddFirstNotebook() throws {
        
        XCTAssertTrue(notebooksListState.isEmpty)
        
        notebooksListState.addFirstNotes()
        // list should not be empty
        XCTAssertFalse(notebooksListState.isEmpty)
    }
    
    
    func testAddNotebookBelow() throws {
        notebooksListState.addFirstNotes()
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        notebooksListState.insertBelow(ref: selectedNotebook)
        XCTAssertTrue(notebooksListState.notesHierarchy.notes.count == 2)
        
        // add another two notebooks
        notebooksListState.insertBelow(ref: selectedNotebook)
        notebooksListState.insertBelow(ref: selectedNotebook)
        XCTAssertTrue(notebooksListState.notesHierarchy.notes.count == 4)
    }
    
    func testAddNotebookInside() throws {
        notebooksListState.addFirstNotes()
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        notebooksListState.insertInside(ref: selectedNotebook)
        XCTAssertNotNil(selectedNotebook.children)
        XCTAssertTrue(selectedNotebook.children!.count == 1)
        
        // add another two notebooks
        notebooksListState.insertInside(ref: selectedNotebook)
        notebooksListState.insertInside(ref: selectedNotebook)
        XCTAssertTrue(selectedNotebook.children!.count == 3)
    }
    
    func testAddNotebookBelowNested() throws {
        notebooksListState.addFirstNotes()
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        notebooksListState.insertInside(ref: selectedNotebook)
        
        guard let nestedNotebook = notebooksListState.notesHierarchy.notes.first?.children?.first?.notebookRef else {
            XCTFail("just aaded nested notebook should exists")
            return
        }
        
        // add two notebooks below a nested notebook
        notebooksListState.insertBelow(ref: nestedNotebook)
        notebooksListState.insertBelow(ref: nestedNotebook)
        XCTAssertTrue(nestedNotebook.parent?.children?.count == 3)
    }
    
    func testAddNotebookInsideNested() throws {
        notebooksListState.addFirstNotes()
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        notebooksListState.insertInside(ref: selectedNotebook)
        
        guard let nestedNotebook = notebooksListState.notesHierarchy.notes.first?.children?.first?.notebookRef else {
            XCTFail("just aaded nested notebook should exists")
            return
        }
        
        // add notebook inside a nested notebook
        notebooksListState.insertInside(ref: nestedNotebook)
        
        XCTAssertTrue(nestedNotebook.children?.count == 1)
    }
    
    
    // MARK: - Remove Notebooks
    func testRemoveFirstNotebook() throws {
        notebooksListState.addFirstNotes()
        
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        
        notebooksListState.deleteNotebook(ref: selectedNotebook)
        XCTAssertTrue(notebooksListState.notesHierarchy.notes.isEmpty)
    }
    
    func testRemoveSameLevelNotebooks() throws {
        notebooksListState.addFirstNotes()
        
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        
        notebooksListState.insertBelow(ref: selectedNotebook)
        notebooksListState.insertBelow(ref: selectedNotebook)
        
        // 1
        notebooksListState.deleteNotebook(ref: selectedNotebook)
        
        // 2
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("notebook should exists")
            return
        }
        notebooksListState.deleteNotebook(ref: selectedNotebook)
        
        // 3
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("notebook should exists")
            return
        }
        notebooksListState.deleteNotebook(ref: selectedNotebook)
        
        XCTAssertTrue(notebooksListState.notesHierarchy.notes.isEmpty)
    }
    
    func testRemoveNestedLevelNotebooks() throws {
        notebooksListState.addFirstNotes()
        
        guard let selectedNotebook = notebooksListState.notesHierarchy.notes.first?.notebookRef else {
            XCTFail("first notebook should exists")
            return
        }
        // insert nested child
        notebooksListState.insertInside(ref: selectedNotebook)
        
        guard let nestedNotebook = selectedNotebook.children?.first else {
            XCTFail("just aaded nested notebook should exists")
            return
        }
        
        // add another 2 child notebooks
        notebooksListState.insertBelow(ref: nestedNotebook)
        notebooksListState.insertBelow(ref: nestedNotebook)
        
        // 1
        notebooksListState.deleteNotebook(ref: nestedNotebook)
        XCTAssertTrue(selectedNotebook.children?.count == 2)
        
        // 2
        guard let nestedNotebook = selectedNotebook.children?.first else {
            XCTFail("notebook should exists")
            return
        }
        notebooksListState.deleteNotebook(ref: nestedNotebook)
        
        // 3
        guard let nestedNotebook = selectedNotebook.children?.first else {
            XCTFail("notebook should exists")
            return
        }
        notebooksListState.deleteNotebook(ref: nestedNotebook)
        
        XCTAssertTrue(selectedNotebook.children?.count == 0)
    }
}
