//
//  StringDiff.swift
//  Tests iOS
//
//  Created by Kiran Sarella on 13/11/22.
//

import XCTest
@testable import Notes_365

final class StringDiffTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWhenAppendedTextToExistingContent() throws {
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
        // TODO: - Have to fix newline issue
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }

    func testWhenAppendedTextToEmptyContent() throws {
        let old =
#"""
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

one
two
three
four
"""#
        
        // TODO: - Have to fix newline issue
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }

    func testWhenNoChangeHappendToEmptyText() throws {
        let old =
#"""
"""#
        
        let new =
#"""
"""#
        
        let diff =
#"""
"""#
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }
    
    func testWhenNoChangeHappendToExistingText() throws {
        let old =
#"""
one
two
"""#
        
        let new =
#"""
one
two
"""#
        
        let diff =
#"""
"""#
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }
    
    func testWhenClearedExistingText() throws {
        let old =
#"""
one
two
"""#
        
        let new =
#"""
"""#
        
        let diff = "\n"
        
        // TODO: - Have to fix newline issue
        
        let result = StringDiff.getChanges(old: old, new: new)
        XCTAssertEqual(diff, result)
    }

}
