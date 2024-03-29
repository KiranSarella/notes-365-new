//
//  Notes_365App.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI
import SwiftData

@main
struct Notes_365App: App {
    var context: ModelContext = {
#if DEBUG
        SharedContext.shared.resetContext(storageType: .local)
//        SharedContext.shared.resetContext(storageType: .mock)
//        SharedContext.shared.resetContext(storageType: .iCloud)
#else
        SharedContext.shared.resetContext(storageType: .iCloud)
#endif
        return SharedContext.shared.getModelContext()
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContext(context)
        .commands {
            SidebarCommands()
        }
        
    }
}
