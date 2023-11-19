//
//  NotebooksListStateTests.swift
//  Notes 365Tests
//
//  Created by kiran ipc on 19/11/23.
//

import XCTest
@testable import Notes_365

final class NotebooksListStateTests: XCTestCase {

    var notebooksListState = NotebooksListState(notebookBusiness: BusinessFactory.createNotebooksFactory())
    
    override func setUpWithError() throws {
        SharedContext.shared.resetContext(mock: true)
        notebooksListState = NotebooksListState(notebookBusiness: BusinessFactory.createNotebooksFactory())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testShouldReturnEmptyNotebooks() async {
        await notebooksListState.loadNotebooks()
        XCTAssertTrue(notebooksListState.isEmpty)
    }
    
    func testShouldContainNotebooksOnCreateFirstNotebook() async {
        await notebooksListState.createNotebook()
        XCTAssertEqual(notebooksListState.notebooksHierarchy.childrenCount, 1)
    }
    
    func testShouldContainManyNotebooksOnTopLevelCreation() async {
        await notebooksListState.createNotebook()
        await notebooksListState.createNotebook()
        await notebooksListState.createNotebook()
        await notebooksListState.createNotebook()
        XCTAssertEqual(notebooksListState.notebooksHierarchy.childrenCount, 4)
    }

    func testShouldInsertBelow() async {
        await notebooksListState.createNotebook()
        let notebook = notebooksListState.notebooksHierarchy.children.first!
        notebooksListState.insertBelow(ref: notebook)
        XCTAssertEqual(notebooksListState.notebooksHierarchy.childrenCount, 2)
    }
    
    func testShouldInsertBelowMany() async {
        await notebooksListState.createNotebook()
        let notebook = notebooksListState.notebooksHierarchy.children.first!
        notebooksListState.insertBelow(ref: notebook)
        notebooksListState.insertBelow(ref: notebook)
        notebooksListState.insertBelow(ref: notebook)
        notebooksListState.insertBelow(ref: notebook)
        XCTAssertEqual(notebooksListState.notebooksHierarchy.childrenCount, 5)
    }
    
//    func testShouldInsertBelow() async {
//        
//    }
}
