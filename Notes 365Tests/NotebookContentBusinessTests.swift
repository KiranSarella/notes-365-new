//
//  NotebookContentBusinessTests.swift
//  Notes 365Tests
//
//  Created by kiran ipc on 20/11/23.
//

import XCTest
@testable import Notes_365

final class NotebookContentBusinessTests: XCTestCase {

    var business = BusinessFactory.createNotebookContentBusinessFactory()
    
    override func setUpWithError() throws {
        SharedContext.shared.resetContext(mock: true)
        business = BusinessFactory.createNotebookContentBusinessFactory()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldNotReturnContentForNotSaved() throws {
        let notebookContent = try business.fetchNotebookContent(for: UUID())
        XCTAssertNil(notebookContent)
    }

    func testShouldReturnContentForSaved() throws {
        let notebookContent = NotebookContentB(notebookID: UUID(), content: "version 1")
        try business.insert(notebookContent: notebookContent)
        let result = try business.fetchNotebookContent(for: notebookContent.notebookID)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.content, notebookContent.content)
    }
    
    func testShouldNotUpdateForNotInserted() throws {
        let notebookContent = NotebookContentB(notebookID: UUID(), content: "version 1")
        XCTAssertThrowsError(try business.update(notebookContent: notebookContent))
    }
    
    func testShouldUpdateForAlreadyExists() throws {
        let notebookContent = NotebookContentB(notebookID: UUID(), content: "version 1")
        try business.insert(notebookContent: notebookContent)
        notebookContent.content = "version 2"
        XCTAssertNoThrow(try business.update(notebookContent: notebookContent))
        let result = try business.fetchNotebookContent(for: notebookContent.notebookID)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.content, notebookContent.content)
    }
    
}
