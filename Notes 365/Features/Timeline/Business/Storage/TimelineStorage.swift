//
//  TimelineStorage.swift
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
    
    func fetchDayTimelineRecords(for date: Date) throws -> [TimelineData] {
        let year = date.getYear()
        let month = date.getMonth()
        let day = date.getDay()
        
        let predicate = #Predicate<TimelineData> {
            $0.year == year && $0.month == month && $0.day == day
        }
        let sortByTime = SortDescriptor(\TimelineData.updatedTime, order: .reverse)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByTime])
        return try modelContext.fetch(descriptor)
    }
    
    func fetchDayNotebookChange(for id: String) throws -> TimelineData? {
        let predicate = #Predicate<TimelineData> {
            $0.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func save(dayNotebookChange: TimelineData) throws {
        if let existedObj = try fetchDayNotebookChange(for: dayNotebookChange.id) {
            existedObj.sync(newValue: dayNotebookChange)
            try update(dayNotebookChange: existedObj)
        } else {
            try insert(dayNotebookChange: dayNotebookChange)
        }
    }
    
    private func insert(dayNotebookChange: TimelineData) throws {
        print(#function, dayNotebookChange)
        modelContext.insert(dayNotebookChange)
        try modelContext.save()
    }
    
    private func update(dayNotebookChange: TimelineData) throws {
        print(#function, dayNotebookChange)
        try dayNotebookChange.modelContext?.save()
    }
    
//    func delete(dayNotebookChange: DayNotebookChangeData) {
//        print(#function, dayNotebookChange)
//        modelContext.delete(dayNotebookChange)
//    }
    
    func delete(for timelineChangeId: String) throws {
        let contentPredicate = #Predicate<TimelineData> {
            $0.id == timelineChangeId
        }
        var descriptor = FetchDescriptor(predicate: contentPredicate)
        descriptor.fetchLimit = 1
        try modelContext.delete(model: TimelineData.self, where: contentPredicate)
    }
    
//    func discard(timelineChangeId: String) throws {
//        let contentPredicate = #Predicate<DayNotebookChangeData> {
//            $0.id == timelineChangeId
//        }
//        var descriptor = FetchDescriptor(predicate: contentPredicate)
//        descriptor.fetchLimit = 1
//        try modelContext.delete(model: DayNotebookChangeData.self, where: contentPredicate)
//    }
    
    func getFirstAvailableTimelineDate() throws -> Date? {
        let predicate = #Predicate<TimelineData> { _ in true }
        let sortByDate = SortDescriptor(\TimelineData.updatedTime)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByDate])
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
    

    
    
}
