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
        todayTimelineIndex = nil
        
        if let todayIndex = fetchDayTimelineIndex(year: today.getYear(), month: today.getMonth(), day: today.getDay()) {
            self.todayTimelineIndex = todayIndex
        } else {
//            self.todayTimelineIndex = TimelineIndex()
        }
         
    }
    
    
    func fetchTimeline(for year: Int) -> [TimelineContent]? {
        guard let modelContext = modelContext else { return nil }
        
        let predicate = #Predicate<TimelineContent> {
            $0.year == year
        }
        
        let descriptor = FetchDescriptor(predicate: predicate, 
                                         sortBy: [SortDescriptor(\TimelineContent.modifiedDate, order: .reverse)])

        do {
            return try modelContext.fetch(descriptor)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    func fetchMonthTimeline(for year: Int, _ month: Int) -> [TimelineContent]? {
        guard let modelContext = modelContext else { return nil }
        
        let predicate = #Predicate<TimelineContent> {
            $0.year == year && $0.month == month
        }
        
        let descriptor = FetchDescriptor(predicate: predicate, 
                                         sortBy: [SortDescriptor(\TimelineContent.modifiedDate, order: .reverse)])

        do {
            return try modelContext.fetch(descriptor)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    func fetchDayTimeline(for year: Int, _ month: Int, _ day: Int) -> TimelineContent? {
        guard let modelContext = modelContext else { return nil }
        
        let predicate = #Predicate<TimelineContent> {
            $0.year == year && $0.month == month && $0.day == day
        }
        
        let descriptor = FetchDescriptor(predicate: predicate,
                                         sortBy: [SortDescriptor(\TimelineContent.modifiedDate, order: .reverse)])

        do {
            return try modelContext.fetch(descriptor).first
        } catch let err {
            print(err)
            return nil
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
//    func removeTimelineChanges(_ timeline: Timeline) {
//        // remove timeline file
//        removeContent(today: today, fileName: timeline.fileUUID.uuidString)
//        // remove row from metadata file
//        removeFromMetadata(uuid: timeline.fileUUID.uuidString)
//        // remove base version
//        TodayVersionBusiness.removeBaseVersion(for: timeline.fileUUID, modelContext: modelContext!)
//    }
    
//    func removeContent(today: Date, fileName: String) {
//        let folderPath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
//        
//        let fileURL = basePathURL
//            .appendingPathComponent(folderPath)
//            .appendingPathComponent(fileName)
//            .appendingPathExtension("md")
//        //        print(fileURL.path(percentEncoded: false))
//        
//        do {
//            try FileManager.default.removeItem(at: fileURL)
//        } catch let error as NSError {
//            print("Failed deleting from URL: \(fileURL), Error: " + error.localizedDescription)
//        }
//    }
    
    func removeFromMetadata(uuid: String, today: Date = Date()) {
        
        let timelinePath = "\(timelineFolderPath)/\(today.getYear())/\(today.getMonth())/\(today.getDay())"
        let metadataFilePath = timelinePath + "/" + "metadata"
        
        var metadata: String = ""
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return }
        
        let metaFileURL = basePathURL.appendingPathComponent(timelinePath, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: metaFileURL.path) {
            /*
             read metadata file
             form object from it
             remove this file metadata to this object
             write metadat to file
             
             format:
             UUID Timestamp timezone filename filepath
             */
            
            metadata = readBinaryFile(fileName: "metadata", folderPath: timelinePath) ?? ""
            var lines = metadata.components(separatedBy: "\n")
            // find index
            var searchIndex: Int?
            for i in 0..<lines.count {
                let line = lines[i]
                let words = line.components(separatedBy: "\t")
                if words.first == uuid {
                    searchIndex = i
                    break
                }
            }
            
            if let searchIndex = searchIndex {
                // remove object
                lines.remove(at: searchIndex)
                // clean existing metadata and add each one again
                metadata = ""
                for line in lines {
                    if line.count > 0 {
                        metadata = metadata.appending(line)
                        metadata = metadata.appending("\n")
                    }
                }
            }
        }
        
        let fileURL = basePathURL.appendingPathComponent(timelinePath).appendingPathComponent("metadata")
        do {
            // Write to the file
            try metadata.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
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
        
        if newChanges.count == 0 {
            return
        }
        
        // if already exists, then upate
        if let timelineContent = getTimelineContent(today: today, uuid: uuid) {
            timelineContent.content = newChanges
            timelineContent.modifiedDate = today //Date()
        } else {
            // else insert
            let timelineContent = TimelineContent()
            timelineContent.year = today.getYear()
            timelineContent.month = today.getMonth()
            timelineContent.day = today.getDay()
            timelineContent.content = newChanges
            timelineContent.notebookID = uuid
            timelineContent.filename = notebookName
            timelineContent.path = notebookPath
            
            modelContext.insert(timelineContent)
            
            // update timeline index
            if let todayTimelineIndex = todayTimelineIndex {
                todayTimelineIndex.changes.append(timelineContent.id)
            } else {
                // create today timelineasdf
                let newTimelineIndex = TimelineIndex()
                newTimelineIndex.year = today.getYear()
                newTimelineIndex.month = today.getMonth()
                newTimelineIndex.day = today.getDay()
                newTimelineIndex.changes.append(timelineContent.id)
                // save to db
                modelContext.insert(newTimelineIndex)
                todayTimelineIndex = newTimelineIndex
            }
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
    
    
    func readBinaryFile(fileName: String, folderPath: String) -> String? {
        
        guard let basePathURL = EnvironmentState.shared.basePathURL else { return nil }
        
        let fileURL = basePathURL
            .appendingPathComponent(folderPath)
            .appendingPathComponent(fileName)
        
        var readString: String?
        do {
            // Read the file contents
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        return readString
    }
}
