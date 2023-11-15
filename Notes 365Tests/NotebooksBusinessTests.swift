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
    
    func testShouldInsertNotebookInsideFirstLevelParent() async throws {
        let parent = try notebooksBusiness.createNotebook()
        let child = try notebooksBusiness.createNotebook(inside: parent.id, at: nil)
        parent.setChildren(notebooks: [child])
        
        XCTAssertEqual(child.parent, parent)
        
        let storedParent = try notebooksBusiness.getNotebook(for: parent.id)
        XCTAssertTrue(storedParent.containChildNotebooks)
        XCTAssertEqual(storedParent.childrenCount, 1)
        XCTAssertEqual(storedParent.children!.first, child)
    }
    
    func testShouldInsertChildrenInsideFirstLevelParent() async throws {
        let parent = try notebooksBusiness.createNotebook()
        let child1 = try notebooksBusiness.createNotebook(inside: parent.id, at: 0)
        try parent.insertChild(notebook: child1, at: 0)
        let child2 = try notebooksBusiness.createNotebook(inside: parent.id, at: 1)
        try parent.insertChild(notebook: child2, at: 1)
        
        let storedParent = try notebooksBusiness.getNotebook(for: parent.id)
        XCTAssertTrue(storedParent.containChildNotebooks)
        XCTAssertEqual(storedParent.childrenCount, parent.childrenCount)
        XCTAssertEqual(storedParent.children!.first, child1)
        XCTAssertEqual(storedParent.children![1], child2)
    }
    
    func testShouldInsertChildrenInsideSecondLevelParent() async throws {
        let _ = try notebooksBusiness.createNotebook()
        let parentAtLevel1 = try notebooksBusiness.createNotebook()
        let parentAtLevel2 = try notebooksBusiness.createNotebook(inside: parentAtLevel1.id, at: nil)
        parentAtLevel1.setChildren(notebooks: [parentAtLevel2])
        let notebookLevel3 = try notebooksBusiness.createNotebook(inside: parentAtLevel2.id, at: nil)
        parentAtLevel2.appendChildren(notebook: notebookLevel3)
        
        let p2 = try notebooksBusiness.getNotebook(for: parentAtLevel2.id)
        XCTAssertEqual(p2, parentAtLevel2)
        XCTAssertNotNil(p2.children?.first)
        XCTAssertEqual(p2.children!.first, notebookLevel3)
    }
}
