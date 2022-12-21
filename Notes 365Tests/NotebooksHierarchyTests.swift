//
//  NotebooksHierarchyTests.swift
//  Notes 365Tests
//
//  Created by Kiran Sarella on 15/11/22.
//

import XCTest

final class NotebooksHierarchyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testBasic() {
        
        let languages = Notebook(id: UUID(), name: "languages")
        let swift = Notebook(id: UUID(), name: "swift")
        let js = Notebook(id: UUID(), name: "js")
        languages.children = [swift, js]
        
        let patterns = Notebook(id: UUID(), name: "Arch patterns")
        patterns.children = [
            Notebook(id: UUID(), name: "active record"),
            Notebook(id: UUID(), name: "data mapping")
        ]
        
        let notebooks = [languages, patterns]
        
        let result = NotebooksHierarchy.constructHierarchy(notebooks: notebooks, expandedIds: [])
        
//        dump(result)
        
        XCTAssertEqual(result.count, notebooks.count)
        XCTAssertEqual(result.first!.children!.count, notebooks.first!.children!.count)
    }
    
//    func testNotebookReferenceWorking() {
//
//        let languages = Notebook(id: UUID(), name: "languages")
//        let swift = Notebook(id: UUID(), name: "swift")
//        let js = Notebook(id: UUID(), name: "js")
//        languages.friends = [swift, js]
//
//        let patterns = Notebook(id: UUID(), name: "Arch patterns")
//        patterns.friends = [
//            Notebook(id: UUID(), name: "active record"),
//            Notebook(id: UUID(), name: "data mapping")
//        ]
//
//        let notebooks = [languages, patterns]
//
//        var result = UserHierarchy.constructHierarchy(notebooks: notebooks)
//
//        result[0].name = "modified"
//        XCTAssertEqual(result[0].name, notebooks[0].name)
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
