//
//  TimelineCreator.swift
//  Notes 365
//
//  Created by kiran ipc on 24/11/23.
//

import Foundation

class TimelineContentCreator {
    
    static let shared = TimelineContentCreator()
    var timelineBusiness: TimelineBusiness?
    
    private var cachedDayVersions = Set<DayVersionData>()
    
    private init() {
        
    }
    
    func startProviding(for timelineBusiness: TimelineBusiness) {
        self.timelineBusiness = timelineBusiness
        observeNotebookContentChanges()
        observeNotebooksLoadedNotification()
    }
    
    func stopProviding() {
        removeObservingNotebookContentChanges()
        removeObservingNotebooksLoaded()
    }
    
    func observeNotebookContentChanges() {
        logger.debug("observeNotebookContentChanges")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentWillUpdate, object: nil)
    }
    
    func removeObservingNotebookContentChanges() {
        logger.debug("removeObservingNotebookContentChanges")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentWillUpdate, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        logger.debug("handleNotebookChangesNotification")
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let content = notification.userInfo?["content"] as? String
        else { return }
                
        if let dayNotebookChange = prepareTimelineContent(notebookId: notebookId, newContent: content) {
            timelineBusiness?.save(dayNotebookChange: dayNotebookChange)
        } else {
            timelineBusiness?.clean(dayNotebookChange: TimelineB(notebookId: notebookId, date: DateTime.now()))
        }
    }
    
    func prepareTimelineContent(notebookId: UUID, newContent: String) -> TimelineB? {
        logger.debug("\(#function) \(notebookId)")
        guard let dayVersion = getBaseVersion(notebookId) else { return nil }
        let baseContent = dayVersion.content
        let diff = StringDiff.getChanges(old: baseContent, new: newContent)
            .trimmingCharacters(in: .newlines)
        logger.debug("diff: \n\(diff)")
        if diff.count == 0 {
            return nil
        }
        var dayNotebookChange = TimelineB(notebookId: notebookId, date: DateTime.now())
        dayNotebookChange.content = diff
        return dayNotebookChange
    }
    
    private func getBaseVersion(_ notebookId: UUID) -> DayVersionData? {
        let dayVersionID = DayVersionData.createID(for: notebookId, date: DateTime.now())
        // cache hit
        let cachedDayVersion = cachedDayVersions.first { dayVersion in
            dayVersion.id == dayVersionID
        }
        
        if let cachedDayVersion = cachedDayVersion {
            return cachedDayVersion
        } else {
            if let dayBaseVersion = DayVersion.shared.getTodayVersion(for: notebookId) {
                // saved baseversion
                cachedDayVersions.insert(dayBaseVersion)
                return dayBaseVersion
            } else {
                // create new base version
                if let dayBaseVersion = DayVersion.shared.createBaseVersion(for: notebookId) {
                    cachedDayVersions.insert(dayBaseVersion)
                    return dayBaseVersion
                } else {
                    return nil
                }
            }
        }
    }
}

extension TimelineContentCreator {
    
    func observeNotebooksLoadedNotification() {
        logger.debug("observeNotebooksLoadedNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookLoaded(_:)), name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    func removeObservingNotebooksLoaded() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentLoaded, object: nil)
    }
    
    @objc func handleNotebookLoaded(_ notification: Notification) {
        logger.debug("\(#function)")
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let notebookConent = notification.userInfo?["notebook_content"] as? String
        else { return }
        
        let dayVersionData = DayVersionData(notebookID: notebookId)
        cachedDayVersions.remove(dayVersionData)
        
        timelineBusiness?.dayVersionBusiness.createBaseVersionIfNotExists(for: notebookId, with: notebookConent)
    }
}
