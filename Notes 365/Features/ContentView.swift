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
        // do initial checks and configurations
        // show loading until all setup
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
                        try? await Task.sleep(nanoseconds: 12_000_000_000)
                        #if DEBUG
                        // choose environment
                        try chooseEnv.setEnviromment(with: .local)
                        let migrationCheck = UserDefaults.standard.bool(forKey: "migration_check_status")
                        if migrationCheck == false {
                            // in new device - check if migration required
                            let notebooksCount = try BusinessFactory.createNotebooksStorage().fetchNotebooksCount()
                            if notebooksCount > 0 {
                                logger.info("notebooksCount: \(notebooksCount)")
                                logger.info("migration not required")
                            } else {
                                statusMessage = "Migrating data to new structure, please wait.."
                                migrationProcess = MigrationProcess(basePathURL: EnvironmentState.shared.basePathURL)
                                await migrationProcess?.startMigrationProcess()
                            }
                        }
                        // do any operations
                        chooseEnv.enableConfigured()
                        
                        // clean base version
                        DayVersion.shared.cleanOlderDayVersions()
                        #else
                        statusMessage = "checking iCloud settings"
                        // choose environment
                        try chooseEnv.setEnviromment(with: .cloud)
                        statusMessage = "iCloud sync.."
                        let migrationCheck = UserDefaults.standard.bool(forKey: "migration_check_status")
                        if migrationCheck == false {
                            // in new device - check if migration required
                            let notebooksCount = try BusinessFactory.createNotebooksStorage().fetchNotebooksCount()
                            if notebooksCount > 0 {
                                logger.info("notebooksCount: \(notebooksCount)")
                                logger.info("migration not required")
                            } else {
                                statusMessage = "Migrating data to new structure, please wait.."
                                migrationProcess = MigrationProcess(basePathURL: EnvironmentState.shared.basePathURL)
                                await migrationProcess?.startMigrationProcess()
                            }
                        }
                        // do any operations
                        chooseEnv.enableConfigured()
                        // clean base version
                        DayVersion.shared.cleanOlderDayVersions()
                        #endif
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
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            List(selection: $sidebarItemSelected) {
                Label("Timeline", systemImage: "rectangle.stack")
                    .tag(SidebarItem.timeline.id)
                Label("Notebooks", systemImage: "books.vertical")
                    .tag(SidebarItem.notebooks.id)
                Label("Search", systemImage: "magnifyingglass")
                    .tag(SidebarItem.search.id)
                Section("Settings", isExpanded: $settingsExpanded) {
                    Button {
                        showThemes = true
                    } label: {
                        Label("Themes", systemImage: "paintbrush")
                    }
                    Button {
                        showFormattingSymbols = true
                    } label: {
                        Label("Symbols Guide", systemImage: "textformat")
                    }
                    Button {
                        showFeedback = true
                    } label: {
                        Label("Feedback", systemImage: "hand.thumbsup")
                    }
                }
            }
            .navigationTitle("Notes 365")
            .onAppear {
                BusinessFactory.dayVersionInteractor().setupDayVersionCreationProcess()
                BusinessFactory.timelineInteractor().setupTimeineCreationProcess()
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
        detail: {
            let selectedItem = SidebarItem(rawValue: sidebarItemSelected ?? SidebarItem.timeline.id)!
            switch selectedItem {
            case .timeline:
                TimelineBaseView(state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
            case .notebooks:
                NotebooksBaseDetailView(path: $path)
            case .search:
                ContentSearchView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

