//
//  DayProcessor.swift
//  Notes 365
//
//  Created by kiran ipc on 06/12/23.
//

import Foundation


struct DayProcessor: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = String
    var linesIterator: IndexingIterator<Array<DayDate>>
    var basePathURL: URL = EnvironmentState.shared.basePathURL
    let timelineBusiness = TimelineBusinessOld(path: EnvironmentState.shared.basePathURL)
    let timelineStorage = BusinessFactory.createTimelineStorageProvider()
    
    init(monthDates: [Date]) {
        let dayDates = monthDates.map { DayDate(date: $0) }
        linesIterator = dayDates.makeIterator()
    }
    
    mutating func next() async -> Element? {
        if Task.isCancelled { return nil }
        if let line = linesIterator.next() {
            return await prepareContent(for: line)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> DayProcessor {
        self
    }
    
    @MainActor
    func prepareContent(for dayDate: DayDate) async -> String? {
        guard let metadata = timelineBusiness.readDayMetaData(dayDate: dayDate) else {
            return "\(dayDate.date) - no meta data"
        }
        let lines = metadata.components(separatedBy: "\n")
        for await timelineB in DayContentGenerator(lines: lines, today: dayDate.date) {
            try? timelineStorage.save(dayNotebookChange: timelineB)
        }
        return "\(dayDate.date) - saved"
    }
}
