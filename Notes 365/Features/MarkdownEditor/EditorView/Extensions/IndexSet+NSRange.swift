//
//  IndexSet+NSRange.swift
//  
//
//  Created by Khan Winter on 1/12/23.
//

import Foundation

extension NSRange {
    /// Convenience getter for safely creating a `Range<Int>` from an `NSRange`
    var intRange: Range<Int> {
        self.location..<NSMaxRange(self)
    }
}

/// Helpers for working with `NSRange`s and `IndexSet`s.
extension IndexSet {
    /// Initializes the  index set with a range of integers
    init(integersIn range: NSRange) {
        self.init(integersIn: range.intRange)
    }

    /// Remove all the integers in the `NSRange`
    mutating func remove(integersIn range: NSRange) {
        self.remove(integersIn: range.intRange)
    }

    /// Insert all the integers in the `NSRange`
    mutating func insert(integersIn range: NSRange) {
        self.insert(integersIn: range.intRange)
    }

    /// Returns true if self contains all of the integers in range.
    func contains(integersIn range: NSRange) -> Bool {
        return self.contains(integersIn: range.intRange)
    }
}


//extension String {
//    subscript(_ range: NSRange) -> String {
//        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
//        let end = self.index(self.startIndex, offsetBy: range.upperBound)
//        let subString = self[start..<end]
//        return String(subString)
//    }
//    
//    extension String {
//    subscript(_ range: CountableRange<Int>) -> String {
//        let idx1 = index(startIndex, offsetBy: range.lowerBound)
//        let idx2 = index(startIndex, offsetBy: range.upperBound)
//        return String(self[idx1..<idx2])
//    }
//    var count: Int { return characters.count }
//}
