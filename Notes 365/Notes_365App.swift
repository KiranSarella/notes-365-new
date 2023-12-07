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
        SharedContext.shared.resetContext(mock: false)
#else
        SharedContext.shared.resetContext()
#endif
        return SharedContext.shared.getModelContext()
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentWrapperView()
        }
        .modelContext(context)
        .commands {
            SidebarCommands()
        }
    }
}
