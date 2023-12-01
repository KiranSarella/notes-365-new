//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentWrapperView: View {
    @State var chooseEnv = ChooseEnvironment()
    @State private var didError = false
    @State private var errorDetail: Error?
    @State private var showRefresh = false
    @State private var statusMessage = "Loading.. wrapper"
    @Environment(\.modelContext) private var modelContext
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
                        #if DEBUG
                        // choose environment
                        try chooseEnv.setEnviromment(with: .local)
                        // do any operations
                        chooseEnv.enableConfigured()
                        // clean base version
                        DayVersion.shared.cleanOlderDayVersions()
                        #else
                        statusMessage = "checking iCloud settings"
                        // choose environment
                        try chooseEnv.setEnviromment(with: .cloud)
                        statusMessage = "iCloud sync.."
                        
//                        chooseEnv.downloaodCloudDocuments(completion: {
//                            // do any operations
//                            chooseEnv.enableConfigured()
//                        })
                        
                        // do any operations
                        chooseEnv.enableConfigured()
                        // clean base version
                        TodayVersionBusiness.cleanOlderDayVersions()
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

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ChooseEnvironment.self) var chooseEnv
    @Environment(\.modelContext) private var modelContext
    @State private var showThemes = false
    @State private var showFormattingSymbols = false
    @State private var showFeedback = false
    @State private var selectedModeID: Mode.ID? = Mode.timeline.id
    @State private var sidebarItemSelected: SidebarItem.ID? = SidebarItem.timeline.id
    // notebooks related
    //    @State private var selectedNotebookM: Notebook.ID?
    @State private var selectedNotebookM: Notebook?
    @State var notebooksListState = NotebooksListState(notebookBusiness: BusinessFactory.createNotebooksFactory())
    @State var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    var todayVersionBusiness = BusinessFactory.dayVersionInteractor()
    
    @State var timelineExpanded = true
    @State var notebooksExpanded = true
    @State var settingsExpanded = true
    @State var allExpanded = true
    @State var pinsExpanded = true
    @State var selection: Int = 0
    @State private var timelineDetailState = TimelineDetailState(timelineBusiness: BusinessFactory.timelineInteractor())
    @State private var presentedParks: [SidebarItem] = []
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
                SettingsView_iPadOS(showModel: $showThemes)
            }
            .sheet(isPresented: $showFormattingSymbols) {
                EditorSymbolsView()
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView_iPadOS()
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
                TimelineDetailView(state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
            case .notebooks:
                NotebooksBaseDetailView(notebooksListState: $notebooksListState, path: $path)
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

