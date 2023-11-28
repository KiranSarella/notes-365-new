//
//  TimelineContent.swift
//  Notes 365
//
//  Created by kiran ipc on 26/09/23.
//

import Foundation
import SwiftData

class TimelineStorage {
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchDayTimelineRecords(for date: Date) throws -> [DayNotebookChangeData] {
        let year = date.getYear()
        let month = date.getMonth()
        let day = date.getDay()
        
        let predicate = #Predicate<DayNotebookChangeData> {
            $0.year == year && $0.month == month && $0.day == day
        }
        let sortByTime = SortDescriptor(\DayNotebookChangeData.updatedTime, order: .reverse)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByTime])
        return try modelContext.fetch(descriptor)
    }
    
    func fetchDayNotebookChange(for id: String) throws -> DayNotebookChangeData? {
        let predicate = #Predicate<DayNotebookChangeData> {
            $0.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func save(dayNotebookChange: DayNotebookChangeData) throws {
        if let existedObj = try fetchDayNotebookChange(for: dayNotebookChange.id) {
            existedObj.sync(newValue: dayNotebookChange)
            try update(dayNotebookChange: existedObj)
        } else {
            try insert(dayNotebookChange: dayNotebookChange)
        }
    }
    
    private func insert(dayNotebookChange: DayNotebookChangeData) throws {
        print(#function, dayNotebookChange)
        modelContext.insert(dayNotebookChange)
        try modelContext.save()
    }
    
    private func update(dayNotebookChange: DayNotebookChangeData) throws {
        print(#function, dayNotebookChange)
        try dayNotebookChange.modelContext?.save()
    }
    
    func delete(dayNotebookChange: DayNotebookChangeData) {
        print(#function, dayNotebookChange)
        modelContext.delete(dayNotebookChange)
    }
    
    func delete(for timelineChangeId: String) throws {
        let contentPredicate = #Predicate<DayNotebookChangeData> {
            $0.id == timelineChangeId
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        try modelContext.delete(model: DayNotebookChangeData.self, where: contentPredicate)
    }
    
    func getFirstAvailableTimelineDate() throws -> Date? {
        let predicate = #Predicate<DayNotebookChangeData> { _ in true }
        let sortByDate = SortDescriptor(\DayNotebookChangeData.updatedTime)
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.updatedTime
    }
    
//    func fetchTimelineRecords(for ids: Set<String>) throws -> [DayNotebookChangeData] {
//        let predicate = #Predicate<DayNotebookChangeData> {
//            ids.contains($0.id)
//        }
//        let sortByTime = SortDescriptor(\DayNotebookChangeData.updatedTime, order: .reverse)
//        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByTime])
//        return try modelContext.fetch(descriptor)
//    }
    
    /*
    // MARK: - OLD
    func fetchTimelineContent(for id: UUID) -> TimelineContent? {
        let predicate = #Predicate<TimelineContent> {
            $0.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try modelContext.fetch(descriptor).first
        } catch let err {
            print(err)
            return nil
        }
    }
    
    func fetchTimelineContentAsync(for id: UUID) async -> TimelineContent? {
        await withCheckedContinuation { continuation in
            let predicate = #Predicate<TimelineContent> {
                $0.id == id
            }
            var descriptor = FetchDescriptor(predicate: predicate)
            descriptor.fetchLimit = 1
            do {
                continuation.resume(returning: try modelContext.fetch(descriptor).first)
            } catch let err {
                print(err)
                continuation.resume(returning: nil)
            }
        }
    }
    
    func fetchDayTimelineIndex(id: UUID) -> TimelineIndex? {
        let predicate = #Predicate<TimelineIndex> {
            $0.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor).first
        } catch let err {
            print(err)
            return nil
        }
    }
    
    /// day - year, month. day numbers
    func fetchDayTimelineIndex(year: Int, month: Int, day: Int) -> TimelineIndex? {
        print(#function, year, month, day)
        let predicate = #Predicate<TimelineIndex> {
            $0.year == year && $0.month == month && $0.day == day
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor).first
        } catch let err {
            print(err)
            return nil
        }
    }
    
    /// month - year, month
    func fetchMonthTimelineIndex(year: Int, month: Int) -> [TimelineIndex]? {
        let predicate = #Predicate<TimelineIndex> {
            $0.year == year && $0.month == month
        }
        var descriptor = FetchDescriptor(predicate: predicate,
                                         sortBy: [SortDescriptor(\TimelineIndex.day, order: .reverse)])
        descriptor.fetchLimit = 31
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    /// day - year, month. day numbers
    func fetchWeekTimelineIndex(year: Int, month: Int, dayStart: Int, dayEnd: Int) -> [TimelineIndex]? {
        print(#function, year, month, dayStart, dayEnd)
        let predicate = #Predicate<TimelineIndex> {
            $0.year == year && $0.month == month && ($0.day >= dayStart && $0.day <= dayEnd)
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    // MARK: - Remove Timeline
    func removeTimelineChanges(_ timeline: Timeline, _ timelineIndexID: UUID?) {
        if let timelineContent = fetchTimelineContent(for: timeline.changesID) {
            print(#function, timeline.changesID)
            modelContext.delete(timelineContent)
        }
        if let timelineIndexID = timelineIndexID {
            removeTimelineIndex(id: timelineIndexID)
        }
        // remove base version
        TodayVersionBusiness.removeBaseVersion(for: timeline.fileUUID, modelContext: modelContext)
        // update todayTimelineIndex
//        updateTodayTimelineIndex()
    }
    
    func removeTimelineIndex(id: UUID) {
        if let timelineIndex = fetchDayTimelineIndex(id: id) {
            print(#function, timelineIndex.id)
            modelContext.delete(timelineIndex)
        }
    }
    
    func hardRemoveTimelineIndex(_ timelineIndex: TimelineIndex) {
        modelContext.delete(timelineIndex)
        try? modelContext.save()
    }
    
    // MARK: - TimelineContent
    func getTimelineContent(today: Date, uuid: UUID) -> TimelineContent? {
        let year = today.getYear()
        let month = today.getMonth()
        let day = today.getDay()
        // if already exists, then upate
        let predicate = #Predicate<TimelineContent> {
            $0.year == year &&
            $0.month == month &&
            $0.day == day &&
            $0.notebookID == uuid
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch let err {
            print(err)
            return nil
        }
    }
    */
    
    
}
