//
//  DayContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


struct DayContentGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = TimelineB
    var linesIterator: IndexingIterator<Array<String>>
    var today: Date
    
    
    init(lines: [String], today: Date) {
        // remove empty lines
        let lines = lines.map({ $0.count > 0 ? $0 : nil }).compactMap({ $0 })
        linesIterator = lines.makeIterator()
        self.today = today
    }
    
    mutating func next() async -> Element? {
        if Task.isCancelled { return nil }
        if let line = linesIterator.next() {
            return await prepareContent(for: line)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> DayContentGenerator {
        self
    }
    
    @MainActor
    func prepareContent(for line: String) async -> TimelineB? {
        let words = line.components(separatedBy: "\t")
        let uuid =  UUID(uuidString: words[0])!
        var timeline = TimelineB(notebookId: uuid, year: today.getYear(), month: today.getMonth(), day: today.getDay())
        timeline.updatedTime = today
        // fetch content
        if let content = await TimelineBusinessOld(path: EnvironmentState.shared.basePathURL).readContent(today: today, fileName: uuid.uuidString)?.trimmingCharacters(in: .newlines) {
            timeline.content = content
            return timeline
        } else {
            return nil
        }
    }
}
