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
    
    private init() {
        
    }
    
    func startProviding(for timelineBusiness: TimelineBusiness) {
        self.timelineBusiness = timelineBusiness
        observeNotebookContentChanges()
    }
    
    func stopProviding() {
        removeObservingNotebookContentChanges()
    }
    
    func observeNotebookContentChanges() {
        logger.debug("observeNotebookContentChanges")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeObservingNotebookContentChanges() {
        logger.debug("removeObservingNotebookContentChanges")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        logger.debug("handleNotebookChangesNotification")
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let content = notification.userInfo?["content"] as? String
        else { return }
                
        if let dayNotebookChange = prepareTimelineContent(notebookId: notebookId, content: content) {
            timelineBusiness?.save(dayNotebookChange: dayNotebookChange)
        } else {
            timelineBusiness?.clean(dayNotebookChange: DayNotebookChange(notebookId: notebookId, date: DateTime.now()))
        }
    }
    
    func prepareTimelineContent(notebookId: UUID, content: String) -> DayNotebookChange? {
        logger.debug("\(#function) \(notebookId)")
        let dayBaseVersion = DayVersion.shared.getTodayVersion(for: notebookId) ?? ""
        let diff = StringDiff.getChanges(old: dayBaseVersion, new: content)
            .trimmingCharacters(in: .newlines)
        logger.debug("diff: \n\(diff)")
        if diff.count == 0 {
            return nil
        }
        var dayNotebookChange = DayNotebookChange(notebookId: notebookId, date: DateTime.now())
        dayNotebookChange.content = diff
        return dayNotebookChange
    }
}
