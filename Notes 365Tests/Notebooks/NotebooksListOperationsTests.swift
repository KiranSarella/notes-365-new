//
//  AddNotebooksTests.swift
//  Notes 365Tests
//
//  Created by Kiran Sarella on 29/12/22.
//

import XCTest

final class NotebooksListOperationsTests: XCTestCase {

    var notebooksListBusiness: NotebooksListBusiness!
    
    var basePathURL: URL {
        if path == nil {
            path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                in: .userDomainMask).last!
            path!.append(component: "test-env")
        }
        return path!
    }
    
    var path: URL?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try FileManager.default.createDirectory(at: basePathURL, withIntermediateDirectories: true)
        notebooksListBusiness = NotebooksListBusiness(dataManager: DataManager(environment: .customPath(basePathURL)))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try? FileManager.default.removeItem(at: basePathURL)
    }

    /*
     create first notebook
     create inside
     create below
     create 5 levels depth
     */
    
    
    // MARK: - Add Notebooks
    
    func testAddingFirstNotebook() throws {
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: basePathURL.path(percentEncoded: false)))
        
        let notebook = notebooksListBusiness.addFirstNotes()
        
        XCTAssertEqual(notebooksListBusiness.notebooks.count, 1, "noteooks count should be 1")
        XCTAssertEqual(notebooksListBusiness.notebooks.first!.id, notebook.id, "should be same notebook id")
        
        let fileUrl = basePathURL
            .appending(component: notebooksListBusiness.notebooksPath)
            .appending(component: notebook.name)
            .appendingPathExtension("md")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path(percentEncoded: false)))
    }
    
    func testAddingNotebookBelow() throws {
        
        let notebook = notebooksListBusiness.addFirstNotes()
        let (new, parent, refIndex) = notebooksListBusiness.insertBelow(ref: notebook)
        
        XCTAssertEqual(notebooksListBusiness.notebooks.count, 2, "noteooks count should be 2")
        XCTAssertEqual(refIndex, 0, "index should be 0")
        XCTAssertEqual(notebooksListBusiness.notebooks[1].id, new.id, "should be same notebook id")
        XCTAssertNil(parent)
    }
    
    func testAddingNotebookInside() throws {
        
        let notebook = notebooksListBusiness.addFirstNotes()
        let new = notebooksListBusiness.insertInside(ref: notebook)
        
        XCTAssertEqual(notebooksListBusiness.notebooks.count, 1, "noteooks count should be 1")
        XCTAssertEqual(notebooksListBusiness.notebooks.first?.children?.count, 1)
        XCTAssertEqual(notebooksListBusiness.notebooks.first!.children!.first!.id, new.id, "should be same notebook id")
        XCTAssertEqual(notebook.children!.count, 1)
        XCTAssertEqual(notebook.children!.first!.id, new.id)
    }
    
    func testNestedLevels() throws {
        
        let notebook = notebooksListBusiness.addFirstNotes()
        let level1 = notebooksListBusiness.insertInside(ref: notebook)
        let level2 = notebooksListBusiness.insertInside(ref: level1)
        
        XCTAssertNotNil(level2.parent)
        XCTAssertEqual(level2.parent, level1)
        
        addInnerInside(notebook: level2)
        addInnerBelow(notebook: level2)
    }
    
    func addInnerInside(notebook: Notebook) {
        XCTContext.runActivity(named: "Add Inside Nested") { activity in
            let level3 = notebooksListBusiness.insertInside(ref: notebook)
            XCTAssertNotNil(level3.parent)
            XCTAssertEqual(level3.parent, notebook)
        }
    }
    
    func addInnerBelow(notebook: Notebook) {
        XCTContext.runActivity(named: "Add Below Nested") { activity in
            let (new, parent, refIndex) = notebooksListBusiness.insertBelow(ref: notebook)
            XCTAssertEqual(refIndex, 0, "index should be 0")
            XCTAssertNotNil(parent)
            XCTAssertEqual(parent!.children![1].id, new.id)
        }
    }

    
    // MARK: - Remove Notebooks
    func testRemoveNotebook() throws {
        let notebook = notebooksListBusiness.addFirstNotes()
        notebooksListBusiness.deleteNotebook(ref: notebook)
        XCTAssertTrue(notebooksListBusiness.notebooks.isEmpty)
    }
    
    func testRemoveNestedNotebook() throws {
        let notebook = notebooksListBusiness.addFirstNotes()
        let level1 = notebooksListBusiness.insertInside(ref: notebook)
        notebooksListBusiness.deleteNotebook(ref: level1)
        XCTAssertTrue(notebook.children!.isEmpty)
    }
}
