//
//  SharedContext.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import Foundation
import SwiftData

class SharedContext {
    static let shared = SharedContext()
    private var modelContext: ModelContext?
    var mock: Bool = true
    
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
                                            NotebookContentData.self,
                                            DayVersionData.self,
                                            TimelineData.self,
                                            ThemeData.self,
                                           configurations: modelConfiguration)
        modelContext = ModelContext(container)
    }
    
    func createContext() {
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for:
                                            NotebookData.self,
                                            NotebookContentData.self,
                                            DayVersionData.self,
                                            TimelineData.self,
                                            ThemeData.self,
                                           configurations: modelConfiguration)
        modelContext = ModelContext(container)
    }
    
    func createICloudContext() {
        let conf = ModelConfiguration("iCloud.com.sarella.notes365-local")
        let container = try! ModelContainer(for: NotebookData.self, NotebookContentData.self, configurations: conf)
        modelContext = ModelContext(container)
    }
}
