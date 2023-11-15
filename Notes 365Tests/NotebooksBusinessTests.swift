import XCTest
@testable import Notes_365

final class NotebooksBusinessTests: XCTestCase {
    
    var notebooksBusiness = BusinessFactory.createNotebooksFactory(mock: true)
    
    func testExample() throws {
        XCTAssertTrue(true)
    }
    
    func testShouldFetchEmptyNotebooksForEmptyStorage() async throws {
        let notebooks = await notebooksBusiness.fetchNotebooks()
        XCTAssertTrue(notebooks.isEmpty)
    }
    
    func testShouldMatchStartingOrderIdWithFirstNotebook() throws {
        let notebook = try notebooksBusiness.createNotebook()
        XCTAssertEqual(notebook.orderID, notebooksBusiness.startingOrderId)
    }
    
    func testShouldGetSingleNotebookAfterFirstNotebookCreated() async throws {
        let notebook = try notebooksBusiness.createNotebook()
        XCTAssertEqual(notebook.orderID, notebooksBusiness.startingOrderId)
        XCTAssertEqual(notebook.name, "Notebook 1")
        
        let notebooks = await notebooksBusiness.fetchNotebooks()
        XCTAssertFalse(notebooks.isEmpty)
        XCTAssertEqual(notebooks.count, 1)
        XCTAssertEqual(notebooks.first!, notebook)
    }
    
    func testShouldGetTwoNotebooksAfterTwoNotebooksCreated() async throws {
        let notebook1 = try notebooksBusiness.createNotebook()
        let notebook2 = try notebooksBusiness.createNotebook()
        XCTAssertEqual(notebook1.orderID, notebooksBusiness.startingOrderId)
        XCTAssertEqual(notebook1.name, "Notebook 1")
        XCTAssertEqual(notebook2.orderID, notebook1.orderID + 1)
        XCTAssertEqual(notebook2.name, "Notebook 2")
        
        let notebooks = await notebooksBusiness.fetchNotebooks()
        XCTAssertFalse(notebooks.isEmpty)
        XCTAssertEqual(notebooks.count, 2)
        XCTAssertEqual(notebooks.first!, notebook1)
        XCTAssertEqual(notebooks[1], notebook2)
    }
}
