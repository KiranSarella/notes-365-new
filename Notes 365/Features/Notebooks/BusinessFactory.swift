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
    
    static func createModelContext(mock: Bool) throws -> ModelContext {
        if mock {
            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: 
                                                NotebookData.self,
                                               NotebookContent.self,
                                               TodayVersion.self,
                                               TimelineIndex.self,
                                               TimelineContent.self, 
                                               configurations: modelConfiguration)
            return ModelContext(container)
        } else {
            let container = try ModelContainer(for:
                                                NotebookData.self,
                                               NotebookContent.self,
                                               TodayVersion.self,
                                               TimelineIndex.self,
                                               TimelineContent.self)
            return ModelContext(container)
        }
    }
    
    static func createNotebooksStorage(mock: Bool) throws -> NotebooksStorageProvider {
        if mock {
            do {
                let modelContext = try BusinessFactory.createModelContext(mock: true)
                return NotebooksStorageAdapter(modelContext: modelContext)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        } else {
            do {
                let modelContext = try BusinessFactory.createModelContext(mock: false)
                return NotebooksStorageAdapter(modelContext: modelContext)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    static func createNotebooksFactory(mock: Bool = false) -> NotebooksBusiness {
        let storage = try! BusinessFactory.createNotebooksStorage(mock: mock)
        return NotebooksBusiness(storage: storage)
    }
    
    static func createNotebooksFactoryNew(mock: Bool = false) -> NotebooksGateway {
        let storage = try! BusinessFactory.createNotebooksStorage(mock: mock)
        return NotebooksBusiness(storage: storage)
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
