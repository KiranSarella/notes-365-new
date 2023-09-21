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
    
    var todayVersionBusiness = TodayVersionBusiness()
    
    var body: some Scene {
        WindowGroup {
            ContentWrapperView()
        }
        .modelContainer(
            for: [Notebook2.self]
        )
        .commands {
            SidebarCommands()
        }
        .onChange(of: scenePhase) { phase in
            // Doing this while setBaseVersion - in editor 
            //            if phase == .active {
            //                TimelineState.cleanOldBaseVersions()
            //            }
        }
#if os(macOS)
        Settings {
            PreferencesView()
                .environmentObject(store)
        }
        
#endif
    }
}
