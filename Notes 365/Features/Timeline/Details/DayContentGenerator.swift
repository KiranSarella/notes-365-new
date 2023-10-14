//
//  DayContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


struct DayContentGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Timeline?
    var linesIterator: IndexingIterator<Array<UUID>>
    var timelineBusiness: TimelineBusiness
    
    init(lines: [UUID], timelineBusiness: TimelineBusiness) {
        linesIterator = lines.makeIterator()
        self.timelineBusiness = timelineBusiness
    }
    
    mutating func next() async -> Element? {
        print(#function)
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
    func prepareContent(for uuid: UUID) async -> Timeline? {
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Task.isCancelled {
            return nil
        }
        
        print(#function, uuid)
        
        guard let timelineContent = await timelineBusiness.fetchTimelineContentAsync(for: uuid) else {
            print("==no content changes==")
            return nil }
        
        if Task.isCancelled {
            return nil
        }
        
        let timeline = timelineContent.getTimeline()
        
        if Task.isCancelled {
            return nil
        }
        
        print(timelineContent.id, timelineContent.content.count)
        
        return timeline
    }
}
