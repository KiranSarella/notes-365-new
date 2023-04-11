//
//  WeekContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


struct WeekContentGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = DayChanges
    var weekDatesIterator: IndexingIterator<[Date]>
    
    init(days: [Date]) {
        // create iterator list with content available dates
        var contentExistingDates = [Date]()
        
        for day in days {
            if TimelineBusiness(path: EnvironmentState.shared.basePathURL).timelineExists(day: day) {
                contentExistingDates.append(day)
            }
        }
        
        weekDatesIterator = contentExistingDates.makeIterator()
    }
    
    mutating func next() async -> Element? {
        
        if Task.isCancelled {
            return nil
        }
        
        if let dayChanges = weekDatesIterator.next() {
            return await fetchDayMetadata(for: dayChanges)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> WeekContentGenerator {
        self
    }
    
    
    
    func fetchDayMetadata(for date: Date) async -> DayChanges? {
        
        guard let metadata = await TimelineBusiness(path: EnvironmentState.shared.basePathURL).readDayMetaData(date: date) else { return nil }
        
        if Task.isCancelled {
            return nil
        }
        
        // TODO: keeping delay  to fix error
        try? await Task.sleep(nanoseconds: 2_000_000_000)   // ** required in production also
        if Task.isCancelled {
            return nil
        }
        return DayChanges(date: date, metadata: metadata)
    }
}
