import XCTest
@testable import Notes_365

final class NotebooksBusinessTests: XCTestCase {
    
    var notebooksBusiness = BusinessFactory.createNotebooksFactory(mock: true)
    
    override func setUp() async throws {
        notebooksBusiness = BusinessFactory.createNotebooksFactory(mock: true)
    }
    
    func testExample() throws {
        XCTAssertTrue(true)
    }
    
    func testShouldFetchEmptyNotebooksForEmptyStorage() async throws {
        let notebooksHierarchy = try await notebooksBusiness.fetchNotebooksHierarchy()
        XCTAssertNil(notebooksHierarchy)
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
        
        let notebooksHierarchy = try await notebooksBusiness.fetchNotebooksHierarchy()
        XCTAssertNotNil(notebooksHierarchy)
        XCTAssertNotNil(notebooksHierarchy?.children)
        XCTAssertEqual(notebooksHierarchy!.childrenCount, 1)
        XCTAssertEqual(notebooksHierarchy!.children!.first!, notebook)
    }
    
    func testShouldGetTwoNotebooksAfterTwoNotebooksCreated() async throws {
        let notebook1 = try notebooksBusiness.createNotebook()
        let notebook2 = try notebooksBusiness.createNotebook()
       
        let notebooksHierarchy = try await notebooksBusiness.fetchNotebooksHierarchy()
        XCTAssertNotNil(notebooksHierarchy)
        XCTAssertNotNil(notebooksHierarchy?.children)
        XCTAssertEqual(notebooksHierarchy!.childrenCount, 2)
        XCTAssertEqual(notebooksHierarchy!.children!.first!, notebook1)
        XCTAssertEqual(notebooksHierarchy!.children![1], notebook2)
    }
    
    func testShouldInsertNotebookInsideFirstLevelParent() async throws {
        let parent = try notebooksBusiness.createNotebook()
        let child = try notebooksBusiness.createNotebook(inside: parent.id, at: nil)
        parent.setChildren(notebooks: [child])
        
        XCTAssertEqual(child.parent, parent)
        
        let storedParent = try notebooksBusiness.getNotebookWithChildren(for: parent.id)
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
        
        let storedParent = try notebooksBusiness.getNotebookWithChildren(for: parent.id)
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
        
        let p2 = try notebooksBusiness.getNotebookWithChildren(for: parentAtLevel2.id)
        XCTAssertEqual(p2, parentAtLevel2)
        XCTAssertNotNil(p2.children?.first)
        XCTAssertEqual(p2.children!.first, notebookLevel3)
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
        XCTAssertNotNil(n1.parent)
    }
}
