//
//  NotebookContentTests.swift
//  Notes 365Tests
//
//  Created by Kiran Sarella on 05/04/23.
//

import XCTest

final class NotebookContentTests: XCTestCase {

    var notebook: NotebookM!
    var notebooksListState: NotebooksListState!
    var notebookEditorState: NotebookEditorState!
    
//    override init() {
//
//
//        super.init()
//    }
//
//    deinit {
//
//
//    }
    
    override func setUpWithError() throws {
        
        
        // setup test directory environment
        let tempDirUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                  in: .userDomainMask).last!
        
        let baseURL = tempDirUrl.appending(component: "documents-test")
        //        print(baseURL ?? "--")
        
        // path is under XCTestDevices, so using documents folder instead of tmp
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: false)
        
        // it will create a singleton environment state with base url
        try? ChooseEnvironment().setEnviromment(with: .custom(baseURL))
        
        // create list state
        notebooksListState = NotebooksListState()
        
        //        Task {
        notebookEditorState = NotebookEditorState()
        //        }
        
        // make a notebook ready, with empty content
        notebooksListState.addFirstNotes()
        notebook = notebooksListState.notesHierarchy.notes.first
    }

    override func tearDownWithError() throws {
     
        // remove notebook
        notebooksListState.deleteNotebook(ref: notebook.notebook)
        notebook = nil
//
        
        
        // setup test directory environment
        let tempDirUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                  in: .userDomainMask).last!
        
        let baseURL = tempDirUrl.appending(component: "documents-test")
        
        try? FileManager.default.removeItem(at: baseURL)
    }

    func testSaveAndLoadContent() async throws {
        
        let content = """
one
two
three
"""
        
        await notebookEditorState.loadContent(for: notebook.notebook)
//        await MainActor.run {
            notebookEditorState.getNewContent = {
                return await MainActor.run { content }
//                return content
            }
//        }
        
        await notebookEditorState.saveContentChanges()
        
        // load content
        await notebookEditorState.loadContent(for: notebook.notebook)
        let value = notebookEditorState.baseContent
        print(value)
        print(content)
        XCTAssertEqual(value, content)
        
    }
    
    
}
