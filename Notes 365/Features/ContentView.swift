//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentWrapperView: View {
    let themes = ThemeState.shared
    @State var chooseEnv = ChooseEnvironment()
    @State private var didError = false
    @State private var errorDetail: Error?
    @State private var showRefresh = false
    @State private var statusMessage = "Loading.."
    @State var migrationProcess: MigrationProcess?
    
    var body: some View {
//        ContentView()
//            .environment(chooseEnv)
        
        
//         do initial checks and configurations
//         show loading until all setup
        if chooseEnv.isConfigured == false {
            if showRefresh {
                VStack {
                    Text(errorDetail?.localizedDescription ?? "")
                        .padding()
                    Button("Refresh") {
                        showRefresh = false
                    }
                }
                .padding()
            } else {
                HStack {
                    Text(statusMessage)
                }
                .task {
                    do {
                        logger.info("wait for icloud sync")
//                        try? await Task.sleep(nanoseconds: 12_000_000_000)
//                        #if DEBUG
//                        // choose environment
//                        try chooseEnv.setEnviromment(with: .local)
//                        
//                        migrationProcess = MigrationProcess(basePathURL: EnvironmentState.shared.basePathURL)
//                        if migrationProcess?.isMigrationDone() == false {
//                            statusMessage = "Migrating data to new structure, please wait.."
//                            await migrationProcess?.startMigrationProcess(byResetDB: true)
//                        }
//                        // do any operations
//                        chooseEnv.enableConfigured()
//                        
//                        // clean base version
//                        DayVersion.shared.cleanOlderDayVersions()
//                        #else
//                        statusMessage = "checking iCloud settings"
//                        // choose environment
//                        try chooseEnv.setEnviromment(with: .cloud)
//                        // migration
//                        migrationProcess = MigrationProcess(basePathURL: EnvironmentState.shared.basePathURL)
//                        if migrationProcess?.isMigrationDone() == false {
//                            statusMessage = "Migrating data to new structure, please wait.."
//                            await migrationProcess?.startMigrationProcess(byResetDB: true)
//                        }
                        // do any operations
                        chooseEnv.enableConfigured()
                        // clean base version
                        DayVersion.shared.cleanOlderDayVersions()
//                        #endif
                    } catch let error {
                        errorDetail = error
                        didError = true
                    }
                }
                .alert(
                    "iCloud",
                    isPresented: $didError,
                    presenting: errorDetail
                ) { details in
                    Button("OK") {
                        // Handle the retry action.
                        showRefresh = true
                    }
                } message: { error in
                    Text(error.localizedDescription)
                }
            }
        } else {
            ContentView()
                .environment(chooseEnv)
        }
    }
}

public enum SidebarItem: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    case timeline
    case notebooks
    case recents
    case search
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ChooseEnvironment.self) var chooseEnv
    @State var settingsExpanded = true
    @State private var showThemes = false
    @State private var showFormattingSymbols = false
    @State private var showFeedback = false
    @State private var sidebarItemSelected: SidebarItem.ID? = SidebarItem.timeline.id
    @State private var selectedNotebookM: Notebook?
    @State var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    var todayVersionBusiness = BusinessFactory.dayVersionInteractor()
    @State private var timelineDetailState = TimelineBaseViewState(timelineBusiness: BusinessFactory.timelineInteractor())
    @State private var path = NavigationPath()
    @State private var horizontalCalendarViewState = HorizontalCalendarViewState()
    let cloudKitSync = CloudKitSync()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            VStack {
                List(selection: $sidebarItemSelected) {
                    Label {
                        Text("Timeline")
                    } icon: {
                        Image(systemName: "rectangle.stack")
                    }
                    .tag(SidebarItem.timeline.id)
                        
                    Label {
                        Text("Notebooks")
                    } icon: {
                        Image(systemName: "books.vertical")
                    }
                    .tag(SidebarItem.notebooks.id)
                    
                    Label {
                        Text("Recents")
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .tag(SidebarItem.recents.id)
                    
                    Label {
                        Text("Search")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                    .tag(SidebarItem.search.id)
                    
                    Section("Settings", isExpanded: $settingsExpanded) {
                        Button {
                            showThemes = true
                        } label: {
                            Label {
                                Text("Themes")
                            } icon: {
                                Image(systemName: "paintbrush")
                            }
                        }
                        Button {
                            showFormattingSymbols = true
                        } label: {
                            Label {
                                Text("Symbols Guide")
                            } icon: {
                                Image(systemName: "textformat")
                            }
                        }
                        Button {
                            showFeedback = true
                        } label: {
                            Label {
                                Text("Feedback")
                            } icon: {
                                Image(systemName: "hand.thumbsup")
                            }
                        }
                    }
                    
//                    if cloudKitSync.isImportDone == false {
//                        ProgressView("Syncing..")
//                    }
                }
                .navigationTitle("Notes 365")
                .onAppear {
                    BusinessFactory.dayVersionInteractor().setupDayVersionCreationProcess()
                    BusinessFactory.timelineInteractor().setupTimeineCreationProcess()
                    BusinessFactory.recentsInteractor().setupRecentsAddingProcess()
                }
                .sheet(isPresented: $showThemes) {
                    ThemesBaseView()
                }
                .sheet(isPresented: $showFormattingSymbols) {
                    EditorSymbolsView()
                }
                .sheet(isPresented: $showFeedback) {
                    FeedbackView()
                }
                .onAppear {
                    ThemeState.shared.updateColorScheme(colorScheme)
                }
                .onChange(of: colorScheme, { oldValue, newValue in
                    if ThemeState.shared.colorScheme != newValue {
                        ThemeState.shared.updateColorScheme(newValue)
                    }
                })
                .onChange(of: sidebarItemSelected) { oldValue, newValue in
                    if newValue == SidebarItem.timeline.rawValue {
                        path = NavigationPath()
                    }
                }
            }
            
        }
        detail: {
            let selectedItem = SidebarItem(rawValue: sidebarItemSelected ?? SidebarItem.timeline.id)!
            switch selectedItem {
            case .timeline:
                TimelineBaseView(state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
            case .notebooks:
                NotebooksBaseDetailView(path: $path)
            case .search:
                ContentSearchView()
            case .recents:
                RecentsBaseDetailView(path: $path)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

