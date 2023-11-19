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
    
//    static func createModelContext(mock: Bool) throws -> ModelContext {
//        if mock {
//            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
//            let container = try ModelContainer(for: 
//                                                NotebookData.self,
//                                               NotebookContent.self,
//                                               TodayVersion.self,
//                                               TimelineIndex.self,
//                                               TimelineContent.self, 
//                                               configurations: modelConfiguration)
//            return ModelContext(container)
//        } else {
//            if let modelContext = SharedContext.shared.modelContext {
//                return modelContext
//            } else {
//                let container = try ModelContainer(for:
//                                                    NotebookData.self,
//                                                   NotebookContent.self,
//                                                   TodayVersion.self,
//                                                   TimelineIndex.self,
//                                                   TimelineContent.self)
//                return ModelContext(container)
//            }
//        }
//    }
    
    static func createNotebooksStorage() -> NotebooksStorageProvider {
        let modelContext = SharedContext.shared.getModelContext()
        return NotebooksStorageAdapter(modelContext: modelContext)
    }
    
    static func createNotebooksFactory() -> NotebooksRequester {
        let storage = BusinessFactory.createNotebooksStorage()
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

class SharedContext {
    static let shared = SharedContext()
    private var modelContext: ModelContext?
    var mock: Bool = false
    
    func getModelContext() -> ModelContext {
        if let modelContext = modelContext {
            return modelContext
        } else {
            if mock {
                createMockContext()
            } else {
                createContext()
            }
            return modelContext!
        }
    }
    
    func resetContext(mock: Bool = false) {
        self.mock = mock
        if self.mock {
            createMockContext()
        } else {
            createContext()
        }
    }
    
    func createMockContext() {
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for:
                                            NotebookData.self,
                                           NotebookContent.self,
                                           TodayVersion.self,
                                           TimelineIndex.self,
                                           TimelineContent.self,
                                           configurations: modelConfiguration)
        modelContext = ModelContext(container)
    }
    
    func createContext() {
        let container = try! ModelContainer(for:
                                            NotebookData.self,
                                           NotebookContent.self,
                                           TodayVersion.self,
                                           TimelineIndex.self,
                                           TimelineContent.self)
        
    }
    
    func createICloudContext() {
        let conf = ModelConfiguration("iCloud.com.sarella.notes365-local")
        let container = try! ModelContainer(for: NotebookData.self, NotebookContent.self, configurations: conf)
        modelContext = ModelContext(container)
    }
}
