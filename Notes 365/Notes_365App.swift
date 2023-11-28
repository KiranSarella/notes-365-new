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
    
    @Environment(\.scenePhase) private var scenePhase
    
    var context: ModelContext = {
        SharedContext.shared.resetContext(mock: false)
        return SharedContext.shared.getModelContext()
    }()
    
    var body: some Scene {
        WindowGroup {
//            BaseBackgroundView()
            ContentWrapperView()
        }
        .modelContext(context)
        .commands {
            SidebarCommands()
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            // Doing this while setBaseVersion - in editor
            //            if phase == .active {
            //                TimelineState.cleanOldBaseVersions()
            //            }
        })
    }
}
