//
//  Notes_365App.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

@main
struct Notes_365App: App {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var store: Store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .commands {
            SidebarCommands()
        }
        .onChange(of: scenePhase) { phase in
            //            if phase == .active {
            //                TimelineState.cleanOldBaseVersions()
            //            }
        }
        .onChange(of: colorScheme) { newValue in
            // capture changes here
            ThemeState.shared.didColorSchemeChange()
        }
#if os(macOS)
        Settings {
            PreferencesView()
                .environmentObject(store)
        }
#endif
    }
}
