//
//  StringDiff.swift
//  Tests iOS
//
//  Created by Kiran Sarella on 13/11/22.
//

import XCTest

final class StringDiffTests: XCTestCase {

    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDiffBasic() throws {
        
        let old =
#"""
one
two
"""#
   
        let new =
#"""
one
two
three
four
"""#
        
        let diff =
#"""

three
four
"""#
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
