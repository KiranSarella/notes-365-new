//
//  SharedContext.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import Foundation
import SwiftData
import CoreData

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
                createICloudContext()
//                createLocalContext()
            }
            return modelContext!
        }
    }
    
    func resetContext(mock: Bool = false) {
        self.mock = mock
        if self.mock {
            createMockContext()
        } else {
//            createICloudContext()
            createLocalContext()
        }
    }
    
    func createMockContext() {
        logger.debug("\(#function)")
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        do {
            let container = try ModelContainer(for:
                                                NotebookData.self,
                                                NotebookContentData.self,
                                                DayVersionData.self,
                                                TimelineData.self,
                                               configurations: modelConfiguration)
            modelContext = ModelContext(container)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func createLocalContext() {
        logger.debug("\(#function)")
//        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        let modelConfiguration = ModelConfiguration()
        do {
            let container = try ModelContainer(for:
                                                NotebookData.self,
                                                NotebookContentData.self,
                                                DayVersionData.self,
                                                TimelineData.self,
                                               configurations: modelConfiguration)
            modelContext = ModelContext(container)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func createICloudContext() {
        logger.debug("\(#function)")
        let icloudPath = "iCloud.com.sarella.notes365-local"
        let modelConfiguration = ModelConfiguration(icloudPath)
        
        // ref: https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices
        do {
        #if DEBUG
            // Use an autorelease pool to make sure Swift deallocates the persistent
            // container before setting up the SwiftData stack.
            try autoreleasepool {
                let desc = NSPersistentStoreDescription(url: modelConfiguration.url)
                let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: icloudPath)
                desc.cloudKitContainerOptions = opts
                // Load the store synchronously so it completes before initializing the
                // CloudKit schema.
                desc.shouldAddStoreAsynchronously = false
                if let mom = NSManagedObjectModel.makeManagedObjectModel(for: [NotebookData.self,
                                                                               NotebookContentData.self,
                                                                               DayVersionData.self,
                                                                               TimelineData.self]) {
                    let container = NSPersistentCloudKitContainer(name: "notes365-local", managedObjectModel: mom)
                    container.persistentStoreDescriptions = [desc]
                    container.loadPersistentStores {_, err in
                        if let err {
                            fatalError(err.localizedDescription)
                        }
                    }
                    // Initialize the CloudKit schema after the store finishes loading.
                    try container.initializeCloudKitSchema()
                    // Remove and unload the store from the persistent container.
                    if let store = container.persistentStoreCoordinator.persistentStores.first {
                        try container.persistentStoreCoordinator.remove(store)
                    }
                }
            }
        #endif
            let modelContainer = try ModelContainer(for:
                                                NotebookData.self,
                                                NotebookContentData.self,
                                                DayVersionData.self,
                                                TimelineData.self,
                                               configurations: modelConfiguration)
            modelContext = ModelContext(modelContainer)
        } catch {
//            fatalError(error.localizedDescription)
            logger.error("\(error)")
            createLocalContext()
        }
    }
}
