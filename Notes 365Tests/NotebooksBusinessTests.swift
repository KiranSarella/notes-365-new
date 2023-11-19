import XCTest
@testable import Notes_365

final class NotebooksBusinessTests: XCTestCase {
    
    var notebooksBusiness = BusinessFactory.createNotebooksFactory()
    
    override func setUp() async throws {
        SharedContext.shared.resetContext(mock: true)
        notebooksBusiness = BusinessFactory.createNotebooksFactory()
    }
    
    func testExample() throws {
        XCTAssertTrue(true)
    }
    
    func testShouldFetchEmptyNotebooksForEmptyStorage() async throws {
        let notebooksHierarchy = try await notebooksBusiness.fetchAllNotebooks()
        XCTAssertTrue(notebooksHierarchy.isEmpty)
    }
    
    func testShouldCreateRootNotebookAfterFirstNotebookCreated() async throws {
        let notebook = try notebooksBusiness.createNotebook()
        XCTAssertEqual(notebook.name, "Notebook 1")
        let root = try notebooksBusiness.getRootNotebookOnly()
        XCTAssertNotNil(root)
    }
    
    func testShouldGetSingleNotebookAfterFirstNotebookCreated() async throws {
        let notebook = try notebooksBusiness.createNotebook()
        XCTAssertEqual(notebook.name, "Notebook 1")
        
        let notebooksRows = try await notebooksBusiness.fetchAllNotebooks()
        XCTAssertFalse(notebooksRows.isEmpty)
        XCTAssertEqual(notebooksRows.count, 2)
    }
    
    func testShouldGetTwoNotebooksAfterTwoNotebooksCreated() async throws {
        let notebook1 = try notebooksBusiness.createNotebook()
        let notebook2 = try notebooksBusiness.createNotebook()
       
        let notebooksRows = try await notebooksBusiness.fetchAllNotebooks()
        XCTAssertFalse(notebooksRows.isEmpty)
        XCTAssertEqual(notebooksRows.count, 3)
    }
    
    func testShouldInsertNotebookInsideFirstLevelParent() async throws {
        let parent = try notebooksBusiness.createNotebook()
        let child = try notebooksBusiness.createNotebook(inside: parent, below: nil, children: nil)
        
        let notebookB = try notebooksBusiness.getNotebook(id: parent.id)
        XCTAssertTrue(notebookB.containChildNotebooks)
        XCTAssertEqual(notebookB.childrenCount, 1)
        XCTAssertEqual(notebookB.childrenIds!.first, child.id)
    }
    
    
    func testShoundNotFetchRootNotebookForEmptyStorage() throws {
        let rootNotebook = try notebooksBusiness.getRootNotebookOnly()
        XCTAssertNil(rootNotebook)
    }
    
    func testShouldReturnRootNotebookAfterCreation() throws {
        let rootNotebook = try notebooksBusiness.createRootNotebook()
        XCTAssertEqual(rootNotebook.name, "root")
    }
    
    func testRaiseExceptionWhenTryingToCreateRootNotebookIfAlreadyExits() throws {
        let _ = try notebooksBusiness.createRootNotebook()
        XCTAssertThrowsError(try notebooksBusiness.createRootNotebook())
    }
    
    func testShouldCreateRootAndChildNotebook() throws {
        let n1 = try notebooksBusiness.createNotebook()
        XCTAssertNotNil(n1.parentId)
    }
}
