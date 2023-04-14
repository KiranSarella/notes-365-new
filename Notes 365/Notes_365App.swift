//
//  Notes_365App.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

@main
struct Notes_365App: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var todayVersionBusiness = TodayVersionBusiness()
    var timelineCreatorBusiness = TimelineCreatorBusiness()
    
    var body: some Scene {
        WindowGroup {
            ContentWrapperView()
        }
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
