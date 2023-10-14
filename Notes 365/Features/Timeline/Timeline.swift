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
class DayIndex: Identifiable {
    
    var id: UUID = UUID()
    var dateString: String = ""//Date().string(withFormat: "yyyy-MM-dd")
    var changes = [UUID]()
    
    var timelines = [Timeline]()
    
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
    var dayChanges: DayChanges = DayChanges(timelineIndex: TimelineIndex())
    
    init(timelineIndex: TimelineIndex) {
        self.id = timelineIndex.id
        self.dateString = timelineIndex.dateString
        self.changes = timelineIndex.changes
        print(#function, dateString)
    }
    
    
//    func createDayContent(timelines: [Timeline], for date: Date) async -> DayChanges? {
//        
//        return await withUnsafeContinuation { continuation in
//            
//            DispatchQueue.main.async {
//                if Task.isCancelled {
//                    continuation.resume(returning: nil)
//                }
//                
//                let dayChange = DayChanges(notes: timelines, date: date, metadata: "")
//                
//                continuation.resume(returning: dayChange)
//            }
//            
//        }
//        
//        // TODO: keeping delay  to fix error
////        try? await Task.sleep(nanoseconds: 4_000_000_000)   // ** required in production also
////        if Task.isCancelled {
////            return nil
////        }
////        return dayChange
//    }
    
//    func prepareDayChanges(timelineContents: [TimelineContent]) {
//        
//        DispatchQueue.main.async {
//            let timelines = timelineContents.map { $0.getTimeline() }
//            
//            self.dayChanges = DayChanges(notes: timelines, date: self.date, metadata: "")
//            // Delay the task by 1 second:
////            try await Task.sleep(nanoseconds: 2_000_000_000)
//            self.isDataLoaded = true
////            print(self.dayChanges)
//        }
//         
//    }
}

public struct Timeline: Identifiable {
    public let id: UUID = UUID()
    var changesID: UUID
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
