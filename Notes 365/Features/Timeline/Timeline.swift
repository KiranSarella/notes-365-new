//
//  TimelineThree.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation
import Combine
import UIKit


/*
 each timeline index refers to one day.
 */
@Observable
class DayIndex {
    var id: UUID = UUID()
    var dateString: String = ""//Date().string(withFormat: "yyyy-MM-dd")
    var changes = [UUID]()
    
//    @Transient
//    var timelineContents: [TimelineContent]?
    
    var date: Date {
        dateString.toLocalDate(withFormat: "yyyy-MM-dd")!
    }
    
    var formattedDate: String {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return date.formatted(date: .abbreviated, time: .omitted)
        } else {
            return date.formatted(date: .complete, time: .omitted)
        }
        
//        if date.isSameDayAs(Date()) {
//            return "Today"
//        } else if date.isSameDayAs(Date().dayBefore) {
//            return "Yesterday"
//        } else {
//            if UIDevice.current.userInterfaceIdiom == .phone {
//                return date.formatted(date: .abbreviated, time: .omitted)
//            } else {
//                return date.formatted(date: .complete, time: .omitted)
//            }
//        }
    }
    
    var isDataLoaded = false
    var dayChanges: DayChanges!
    
    init(timelineIndex: TimelineIndex) {
        self.id = timelineIndex.id
        self.dateString = timelineIndex.dateString
        self.changes = timelineIndex.changes
        print(#function, dateString)
    }
    
    func loadTimelineContent(_ business: TimelineBusiness) {
        
        print(#function, dateString)
        
        // fetch all timeline contents in a single day
        var timelineContents = [TimelineContent]()
        
        for id in changes {
            if let timelineContent = business.fetchTimelineContent(for: id) {
                timelineContents.append(timelineContent)
            }
        }
        // prepare to display
        prepareDayChanges(timelineContents: timelineContents)
    }
    
    func prepareDayChanges(timelineContents: [TimelineContent]) {
        
//        guard let timelineContents = timelineContents else { return }
        
        DispatchQueue.main.async {
            var timelines = [Timeline]()
            for timelineContent in timelineContents {
                timelines.append(timelineContent.getTimeline())
            }
        
            self.dayChanges = DayChanges(notes: timelines, date: self.date, metadata: "")
            // Delay the task by 1 second:
//            try await Task.sleep(nanoseconds: 2_000_000_000)
            self.isDataLoaded = true
//            print(self.dayChanges)
        }
         
    }
}

public struct Timeline: Identifiable {
    public let id: UUID = UUID()
    var fileUUID: UUID
    var fileName: String
    var filePath: String
    var content: String?
    var attriburedString: AttributedString?
    var needUpdate = true
    var isNotebookExists = true
    // UI optimazation related
    var editorView: EditorView = EditorView()
    var height: CGFloat = 0
    var isConfigured = false
    var themeID: UUID = UUID()
    var width: CGFloat = 0
}

extension Timeline: Equatable {
    
}

extension Timeline {
    
    mutating func updateWithTheme(theme: MarkdownTheme) async {
        
        // generate attribured string
        let markdownAttrStr = MarkdownAttriburedString(theme: theme)
        let newAttS = markdownAttrStr.getAttriburedString(forMarkdown: self.content!)
        self.attriburedString = AttributedString(newAttS)
    }

    var isRefreshRequired: Bool {
        (themeID != editorView.theme.id) || (width != editorView.textView.intrinsicContentSize.width)
    }
}
