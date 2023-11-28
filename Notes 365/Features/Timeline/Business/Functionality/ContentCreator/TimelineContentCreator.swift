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
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotebookChangesNotification(_:)), name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    func removeObservingNotebookContentChanges() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notebookContentUpdated, object: nil)
    }
    
    @objc func handleNotebookChangesNotification(_ notification: Notification) {
        guard
            let notebookId = notification.userInfo?["notebook_id"] as? UUID,
            let content = notification.userInfo?["content"] as? String
        else { return }
                
        if let dayNotebookChange = prepareTimelineContent(notebookId: notebookId, content: content) {
            timelineBusiness?.save(dayNotebookChange: dayNotebookChange)
        }
    }
    
    func prepareTimelineContent(notebookId: UUID, content: String) -> DayNotebookChange? {
        print(#function, notebookId)
        let dayBaseVersion = DayVersion.shared.getTodayVersion(for: notebookId) ?? ""
        let diff = StringDiff.getChanges(old: dayBaseVersion, new: content)
//            .trimmingCharacters(in: .newlines)
        // TODO: - how to detect if a line is deleted?
        if diff.count == 0 {
            return nil
        }
        var dayNotebookChange = DayNotebookChange(notebookId: notebookId, date: DateTime.now())
        dayNotebookChange.content = diff
        return dayNotebookChange
    }
}
