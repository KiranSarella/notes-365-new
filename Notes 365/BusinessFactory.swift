//
//  File.swift
//  
//
//  Created by kiran ipc on 15/11/23.
//

import Foundation
import SwiftData

//protocol NotebooksBusinessFactory {
//    func makeBusinessObject() -> NotebooksStorageProvider
//}

// Factory Creator
class BusinessFactory {
    
    static func createNotebooksStorage() -> NotebooksStorageProvider {
        let modelContext = SharedContext.shared.getModelContext()
        return NotebooksStorageAdapter(modelContext: modelContext)
    }
    
    static func createNotebookContentStorageProvider() -> NotebookContentStorageProvider {
        let modelContext = SharedContext.shared.getModelContext()
        return NotebookContentStorageAdapter(modelContext: modelContext)
    }
    
    static func createTimelineStorageProvider() -> TimelineStorageProvider {
        let modelContext = SharedContext.shared.getModelContext()
        return TimelineStorageAdapter(modelContext: modelContext)
    }
    
    static func createNotebooksFactory() -> NotebooksRequester {
        let storage = BusinessFactory.createNotebooksStorage()
        return NotebooksBusiness(storage: storage)
    }
    
    static func createNotebookContentStorage() -> NotebookContentStorageProvider {
        let modelContext = SharedContext.shared.getModelContext()
        return NotebookContentStorageAdapter(modelContext: modelContext)
    }
    
    static func createNotebookContentBusinessFactory() -> NotebookContentRequester {
        let storage = BusinessFactory.createNotebookContentStorage()
        return NotebookContentBusinessNew(storage: storage)
    }
    
    
    static func timelineInteractor() -> TimelineInteractor {
        let modelContext = SharedContext.shared.getModelContext()
        let storage = TimelineStorageAdapter(modelContext: modelContext)
        return TimelineBusiness(storage: storage)
    }
    
    static func dayVersionInteractor() -> DayVersionInteractor {
        let modelContext = SharedContext.shared.getModelContext()
        let storage = TodayVersionStorageAdapter(modelContext: modelContext)
        return TodayVersionBusiness(storage: storage)
    }
    
    static func contentSearchInteractor() -> ContentSearchInteractor {
        let modelContext = SharedContext.shared.getModelContext()
        let storage = ContentSearchStorageAdapter(modelContext: modelContext)
        return ContentSearchBusiness(storage: storage)
    }
    
    static func themeInteractor() -> ThemeInteractor {
        let modelContext = SharedContext.shared.getModelContext()
        let storage = ThemeStorageAdapter(modelContext: modelContext)
        return ThemeBusiness(storage: storage)
    }
    
}

//class NotebooksBusinessGenerator: NotebooksBusinessFactory {
//    
//    func makeBusinessObject() -> NotebooksStorageProvider {
//        
//    }
//}
//
//class MockNotebooksBusinessGenerator: NotebooksBusinessFactory {
//    
//    func makeBusinessObject() -> NotebooksStorageProvider {
//        
//    }
//}

