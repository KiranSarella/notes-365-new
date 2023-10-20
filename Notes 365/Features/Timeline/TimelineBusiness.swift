//
//  TimelineBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation
import SwiftData


class TimelineBusiness {
    
    let timelineFolderPath = Constants.timelineFolderName
    
    var modelContext: ModelContext?
    
    var todayTimelineIndex: TimelineIndex?
    
    var count = -5
    var today = Date()
//    var today = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    
    init() {
        
    }
    
    func setAsBeforeDay() {
        
        count -= 1
        today = Calendar.current.date(byAdding: .day, value: count, to: Date())!
        print(#function, today)
        
        updateTodayTimelineIndex()
    }
    
    func updateTodayTimelineIndex() {
        
        if let todayIndex = fetchDayTimelineIndex(year: today.getYear(), month: today.getMonth(), day: today.getDay()) {
            print("today index: ", todayIndex.id, todayIndex.changes)
            self.todayTimelineIndex = todayIndex
            
//            hardRemoveTimelineIndex(todayIndex)
//            
        } else {
            todayTimelineIndex = nil
        }
    }

    func fetchTimelineContent(for id: UUID) -> TimelineContent? {
        guard let modelContext = modelContext else { return nil }
        
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
    
    // MARK: - async
    func fetchTimelineContentAsync(for id: UUID) async -> TimelineContent? {
        
        await withCheckedContinuation { continuation in
            
            guard
                let modelContext = modelContext
            else {
                continuation.resume(returning: nil)
                return
            }
            
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
    
    func loadDayTimelineContentAsync(_ uuids: [UUID]) async -> [TimelineContent] {
        
        // fetch all timeline contents in a single day
        var timelineContents = [TimelineContent]()
        
        for id in uuids {
            if let timelineContent = await fetchTimelineContentAsync(for: id) {
                timelineContents.append(timelineContent)
            }
        }
        
        return timelineContents
    }
    
    
//    func fetchTimelineIndex(after date: Date) -> [TimelineIndex]? {
//        guard let modelContext = modelContext else { return nil }
//        
//        let predicate = #Predicate<TimelineIndex> { _ in
//            true
//        }
//        
//        var descriptor = FetchDescriptor(predicate: predicate,
//                                         sortBy: [SortDescriptor(\TimelineIndex.dateString, order: .reverse)])
//        descriptor.fetchLimit = 50
//        descriptor.includePendingChanges = true
//        
//        do {
//            return try modelContext.fetch(descriptor)
//        } catch let err {
//            print(err)
//            return nil
//        }
//    }
    
    
//    func fetchAllTimelineIndex() -> [TimelineIndex]? {
//        guard let modelContext = modelContext else { return nil }
//        
//        let predicate = #Predicate<TimelineIndex> { _ in
//            true
//        }
//        
//        var descriptor = FetchDescriptor(predicate: predicate,
//                                         sortBy: [SortDescriptor(\TimelineIndex.dateString, order: .reverse)])
//        descriptor.includePendingChanges = true
//        
//        do {
//            return try modelContext.fetch(descriptor)
//        } catch let err {
//            print(err)
//            return nil
//        }
//    }
    
    func fetchDayTimelineIndex(id: UUID) -> TimelineIndex? {
        guard let modelContext = modelContext else { return nil }
        
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
        guard let modelContext = modelContext else { return nil }
        
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
        guard let modelContext = modelContext else { return nil }
        
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
        guard let modelContext = modelContext else { return nil }
        
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
    
//    func fetchDayTimeline(for id: UUID) -> [TimelineContent]? {
//        guard let modelContext = modelContext else { return nil }
//        
//        let predicate = #Predicate<TimelineContent> {
//            $0.year == year && $0.month == month && $0.day == day
//        }
//        
//        let descriptor = FetchDescriptor(predicate: predicate,
//                                         sortBy: [SortDescriptor(\TimelineContent.modifiedDate, order: .reverse)])
//
//        do {
//            return try modelContext.fetch(descriptor)
//        } catch let err {
//            print(err)
//            return nil
//        }
//    }
    
    
    // MARK: - Remove Timeline
    func removeTimelineChanges(_ timeline: Timeline, _ timelineIndexID: UUID?) {
        
        guard let modelContext = modelContext else { return }
        
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
        updateTodayTimelineIndex()
    }
    
    func removeTimelineIndex(id: UUID) {
        guard let modelContext = modelContext else { return }
        
        if let timelineIndex = fetchDayTimelineIndex(id: id) {
            print(#function, timelineIndex.id)
            modelContext.delete(timelineIndex)
        }
    }
    
    func hardRemoveTimelineIndex(_ timelineIndex: TimelineIndex) {
        guard let modelContext = modelContext else { return }
        
        modelContext.delete(timelineIndex)
        try? modelContext.save()
    }
}

// MARK: - Timeline Creation
extension Notification.Name {
    public static let notebookContentUpdated = Notification.Name("com.notes365.notebookContentUpdated")
}

extension TimelineBusiness {
    
    func registerNotebookChangesNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeNotebookChangesNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        guard
            let uuid = notification.userInfo?["id"] as? UUID,
            let notebookName = notification.userInfo?["notebookName"] as? String,
            let notebookPath = notification.userInfo?["notebookPath"] as? [String]
        else { return }
                createTimeline(uuid: uuid, notebookName: notebookName, notebookPath: notebookPath)
        
    }
    
    func createTimeline(uuid: UUID, notebookName: String, notebookPath: [String]) {
        print(#function, notebookName)
        guard let modelContext = modelContext else { return }
        
        
        // get updated content from notebook business
        guard let notebookContent = NotebookContentBusiness.fetchNotebookContent(for: uuid, in: modelContext) else { return }
        // ask todayVersion object to get baseversion
        let baseVersion = TodayVersionBusiness.getBaseVersion(for: uuid, modelContext: modelContext) ?? ""
        // do string diff
        // save to timeline path
        let newChanges = StringDiff.getChanges(old: baseVersion, new: notebookContent.content)
//            .trimmingCharacters(in: .newlines)
        
        // how to detect if a line is deleted?
        print(newChanges)
        if newChanges.count == 0 {
            return
        }
        
        // if already exists, then update
        if let timelineContent = getTimelineContent(today: today, uuid: uuid) {
            timelineContent.content = newChanges
            timelineContent.filename = notebookName
            timelineContent.path = notebookPath
            
            timelineContent.modifiedDate = today //Date()
            
            appendTimelineContentToIndex(timelineContent: timelineContent.id)
        } else {
            // else insert
            let timelineContent = TimelineContent()
            // index
            timelineContent.year = today.getYear()
            timelineContent.month = today.getMonth()
            timelineContent.day = today.getDay()
            timelineContent.notebookID = uuid
            // data
            timelineContent.content = newChanges
            timelineContent.filename = notebookName
            timelineContent.path = notebookPath
            
            modelContext.insert(timelineContent)
            
            appendTimelineContentToIndex(timelineContent: timelineContent.id)
        }
        
        
       
        
        do {
            try modelContext.save()
        } catch let error {
            print(error)
        }
        
        
        /*
         var year: Int = 0
         var month: Int = 0
         var day: Int = 0
         var content = ""
         var notebookID: UUID = UUID()
         var filename = ""
         var path = [String]()
         var modifiedDate = Date()
         */
    }
    
    func appendTimelineContentToIndex(timelineContent: UUID) {
        guard let modelContext = modelContext else { return }
        
        // validate timelineIndex date
        // update timeline index
        if let todayTimelineIndex = todayTimelineIndex, todayTimelineIndex.date.isSameDayAs(Date()) {
            // append if not exists only
            if !todayTimelineIndex.changes.contains(timelineContent) {
                todayTimelineIndex.changes.append(timelineContent)
            }
            
        } else {
            // create today timelineasdf
            let newTimelineIndex = TimelineIndex()
            newTimelineIndex.year = today.getYear()
            newTimelineIndex.month = today.getMonth()
            newTimelineIndex.day = today.getDay()
            newTimelineIndex.changes.append(timelineContent)
            // save to db
            modelContext.insert(newTimelineIndex)
            todayTimelineIndex = newTimelineIndex
        }
    }
    
    // MARK: - TimelineIndex
//    func fetchTimelineIndex(_ date: Date) -> TimelineIndex? {
//        guard let modelContext = self.modelContext else { return nil }
//        
//        let dateString = date.string(withFormat: "yyyy-MM-dd")
//        
//        // if already exists, then update
//        let predicate = #Predicate<TimelineIndex> {
//            $0.dateString == dateString
//        }
//        
//        var descriptor = FetchDescriptor(predicate: predicate)
//        descriptor.fetchLimit = 1
//        
//        do {
//            let results = try modelContext.fetch(descriptor)
//            return results.first
//        } catch let err {
//            print(err)
//            return nil
//        }
//    }
    
    // MARK: - TimelineContent
    func getTimelineContent(today: Date, uuid: UUID) -> TimelineContent? {
        
        guard let modelContext = self.modelContext else {
            return nil
        }
        
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
    
}
