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
    var timelineBusiness: TimelineBusiness
    
    init(days: [Date], timelineBusiness: TimelineBusiness) {
        print("WeekContentGenerator", days)
        self.timelineBusiness = timelineBusiness
        weekDatesIterator = days.makeIterator()
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
        
        print(#function, date)
        
        guard let timelineIndex = self.timelineBusiness.fetchDayTimelineIndex(year: date.getYear(), month: date.getMonth(), day: date.getDay()) else {
            print("timelineIndex - not exists")
            return nil
        }
        
        if Task.isCancelled {
            return nil
        }
        
        // TODO: keeping delay to fix error
        try? await Task.sleep(nanoseconds: 2_000_000_000)   // ** required in production also
        if Task.isCancelled {
            return nil
        }
        return DayChanges(timelineIndex: timelineIndex)
    }
}
