//
//  DayContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation

public struct MonthDate {
    let start: Date
    let end: Date
    
    init(date: Date) {
        (start, end) = date.getMonthStartEndDates()
    }
}

extension MonthDate: Equatable {}
extension MonthDate: Hashable {}


struct MonthContentGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = String
    var linesIterator: IndexingIterator<Array<Int>>
    var year: Int
    var basePathURL: URL = EnvironmentState.shared.basePathURL
    
    init(year: Int) {
        self.year = year
        // remove empty lines
        var months: [Int] = [Int]()
        for i in 1...12 {
            months.append(i)
        }
        linesIterator = months.makeIterator()
    }
    
    mutating func next() async -> Element? {
        if let line = linesIterator.next() {
            return await prepareContent(for: line)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> MonthContentGenerator {
        self
    }
    
    @MainActor
    func prepareContent(for month: Int) async -> String? {
        logger.debug("\(#function) - month: \(month)")
        let monthPathStr = "\(year)/\(month)"
//        
//        try? await Task.sleep(nanoseconds: 5_000_000_000)
//        
//        return Date()
//        
        let fileURL = basePathURL.appendingPathComponent(Constants.timelineFolderName)
            .appendingPathComponent(monthPathStr, isDirectory: true)
        // if month folder exits, else return
        if FileManager.default.fileExists(atPath: fileURL.path) == false {
            logger.debug("file not exits - \(fileURL.absoluteString)")
            return "\(month)"
        } else {
            guard let date = "\(year)-\(month)-\(01)".toLocalDate(withFormat: "yyyy-MM-dd") else { return "\(month)" }
            let monthDates = date.getDaysOfMonth()
            for await _ in DayProcessor(monthDates: monthDates) {
                
            }
            return "good - \(month)"
        }
    }
    
}
