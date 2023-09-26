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
    
    var container: ModelContainer = {
        let conf = ModelConfiguration("iCloud.com.sarella.notes365-local")
//        return try! ModelContainer(for: Notebook.self, NotebookContent.self, configurations: conf)
        do {
            let container = try ModelContainer(for:
                                                Notebook.self, NotebookContent.self, TodayVersion.self,
                                               configurations: conf)
            return container
        } catch {
            print("errror: \(error)")
            // fallback to local container
            return try! ModelContainer(for: Notebook.self, NotebookContent.self, TodayVersion.self)
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentWrapperView()
        }
        .modelContainer(container)
//        .modelContainer(
//            for: [Notebook2.self]
//        )
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
