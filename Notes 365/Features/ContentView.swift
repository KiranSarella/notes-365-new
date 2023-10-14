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
    
    @State private var statusMessage = "Loading.."
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
                        TodayVersionBusiness.cleanBaseVersionIfNeeded(modelContext: modelContext)
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
                        TodayVersionBusiness.cleanBaseVersionIfNeeded()
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
    
    @State private var icloudSyncing = false
    
//    @State private var notesListSyncing = false
//    @State private var notesContentSyncing = false
    
    @State private var selectedModeID: Mode.ID? = Mode.timeline.id
    @State private var sidebarItemSelected: SidebarItem.ID? = SidebarItem.timeline.id
    
    
    // timeline related
//    @State var calendarState = CalendarState.shared
    // notebooks related
//    @State private var selectedNotebookM: Notebook.ID?
    @State private var selectedNotebookM: Notebook?
    @State var notebooksListState = NotebooksListState()
    
//    @State var selectedCalenderType: CalendarType.ID? = CalendarType.day.id
//    
//    @State var selectedCalender: CalendarType? = CalendarType.day
    
    @State var showDetail = false
    
//    @State private var editorState = NotebookEditorState()
    
    private var notebooksListSync = NotebooksListSync(basePathURL: EnvironmentState.shared.basePathURL)
//    private var timelineSync = TimelineSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var todayVersionSync = TodayVersionSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var notebooksContentSync = NotebooksContentSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var deletedListSync = DeletedListSync(basePathURL: EnvironmentState.shared.basePathURL)
    
    @State var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    
    
    var todayVersionBusiness = TodayVersionBusiness()
    
    var bottomViewBackgroundColor: Color {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return Color(uiColor: UIColor.systemGroupedBackground)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return Color(uiColor: UIColor.secondarySystemBackground)
        }
        
        return Color(uiColor: UIColor.systemGroupedBackground)
    }
    
    @State var timelineExpanded = true
    @State var notebooksExpanded = true
    @State var settingsExpanded = true
    
    @State var allExpanded = true
    @State var pinsExpanded = true
    
    @State var selection: Int = 0
    
    @State private var timelineDetailState = TimelineDetailState()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            
            List(selection: $sidebarItemSelected) {
                
                Label("Timeline", systemImage: "rectangle.stack")
                    .tag(SidebarItem.timeline.id)
                Label("Notebooks", systemImage: "books.vertical")
                    .tag(SidebarItem.notebooks.id)
                
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

//                   Label("Formatting Symbols", systemImage: "textformat")
//                        .tag(SidebarItem.formatingSymbols.id)
//                   Label("Feedback", systemImage: "hand.thumbsup")
//                        .tag(SidebarItem.feedback.id)
               }
            }
            .navigationTitle("Notes 365")
            .onAppear {
                todayVersionBusiness.modelContext = modelContext
                notebooksListState.modelContext = modelContext
                
                timelineDetailState.timelineBusiness.modelContext = modelContext
                // used to create new timeline
                timelineDetailState.timelineBusiness.updateTodayTimelineIndex()
            }
            
////                Section(isExpanded: $notebooksExpanded) {
////                    NotebooksListView(icloudSyncing: $icloudSyncing, usersState: notebooksListState, selectedNotebook: $selectedNotebookM)
////                        .frame(height: 500)
////                } header: {
////                    Label("Notebooks", systemImage: "books.vertical")
////                }
//
//                
////                Section("Notebooks", isExpanded: $notebooksExpanded) {
////    
////                    NotebooksListView(icloudSyncing: $icloudSyncing, usersState: notebooksListState, selectedNotebook: $selectedNotebookM)
////                        .frame(height: 500)
////                    
//////                    Section(isExpanded: $allExpanded) {
//////                        
//////                    } header: {
//////                        Label("All", systemImage: "books.vertical")
//////                    }
////                    
////                    Section(isExpanded: $pinsExpanded) {
////                        Text("red")
////                        Text("orange")
////                        Text("green")
////                    } header: {
////                        Label("Pinned", systemImage: "pin")
////                    }
////
//////                    Label("Pinned", systemImage: "pin")
////                    Label("Tags", systemImage: "tag")
////                    Label("Labels", systemImage: "number")
////                    Label("Search", systemImage: "magnifyingglass")
////                }
//                
//                Section("Settings", isExpanded: $settingsExpanded) {
//                    Label("Themes", systemImage: "paintbrush")
//                    Label("Formatting Symbols", systemImage: "textformat")
//                    Label("Feedback", systemImage: "hand.thumbsup")
//                }
//                
//            }
//            .navigationTitle("Notes 365")
//            .listStyle(.inset)
//            .listStyle(.sidebar)
            
            // navigation headings
//            VStack {
            
            
        
            
//                List(Mode.allCases, selection: $selectedModeID) { selectedMode in
//                    HStack(spacing: 0) {
//                        Label(selectedMode.name, systemImage: selectedMode.image)
////                        Image(systemName: selectedMode.image)
////                        Text(selectedMode.name)
////                            .padding(.horizontal)
//                    }
//                    
//                    
//                    
//                    Section("Settings", isExpanded: $settingsExpanded) {
//                        Label("Themes", systemImage: "paintbrush")
//                        Label("Formatting Symbols", systemImage: "textformat")
//                        Label("Feedback", systemImage: "hand.thumbsup")
//                    }
//                }
//                .navigationTitle("Notes 365")
//                Spacer()
//                // bottom view - settings option
//                HStack {
//                    VStack {
//                        Button {
//                            // do sync
//                            // plist
//                            notebooksListSync.initialGatheringSync()
//                            // notebooks
//                            notebooksContentSync.initialGatheringSync()
//                            // timeline
//                            timelineSync.initialGatheringSync()
//                            // today base version
//                            todayVersionSync.initialGatheringSync()
//                            // deleted list
//                            deletedListSync.initialGatheringSync()
//                        } label: {
//                            HStack {
//                                Image(systemName: "arrow.triangle.2.circlepath")
//                                Text("iCloud Sync")
//                                    .padding(.horizontal, 6)
//                                
//                                ProgressView()
//                                    .opacity(icloudSyncing ? 1 : 0)
//                                
//                            }.padding(4)
//                            Spacer()
//                        }
//                        .help("Sync with iCloud")
//                        
//                        Button {
//                            showSettings = true
//                        } label: {
//                            HStack {
//                                Image(systemName: "gearshape")
//                                Text("Settings")
//                                    .padding(.horizontal, 6)
//                            }.padding(4)
//                            Spacer()
//                        }
//                        .help("Settings")
//                    }
//                    Spacer()
//                }
//                .padding()
                .sheet(isPresented: $showThemes) {
                    SettingsView_iPadOS(showModel: $showThemes)
                }
                .sheet(isPresented: $showFormattingSymbols) {
                    EditorSymbolsView()
                }
                .sheet(isPresented: $showFeedback) {
                    FeedbackView_iPadOS()
                }
//            }
//            .frame(minWidth: 180)
//            .background(bottomViewBackgroundColor)
            .onAppear {
                ThemeState.shared.updateColorScheme(colorScheme)
            }
            .onChange(of: colorScheme, { oldValue, newValue in
                if ThemeState.shared.colorScheme != newValue {
                    ThemeState.shared.updateColorScheme(newValue)
                }
            })
            // issue - seleted notebooks is cleared every time on app appear.
//            .onChange(of: scenePhase) { newPhase in
//                if newPhase == .active {
////                    print("Active")
//                    // do sync
//                    notebooksListSync.initialGatheringSync()
//                    notebooksContentSync.initialGatheringSync()
//                } else if newPhase == .inactive {
////                    print("Inactive")
//                } else if newPhase == .background {
////                    print("Background")
//                }
//            }
            
        } 
    
//    content: {
//            // calender and notebooks list
//            if let selectedMode = Mode.getMode(id: selectedModeID) {
//                switch selectedMode {
//                case .timeline:
//                    Text("contentview")
////                        .navigationSplitViewStyle(.prominentDetail)
////                        .navigationSplitViewColumnWidth(min: 0, ideal: 0, max: 0)
////                    TimelineSidebarView(calendarID: $selectedCalenderType)
////                        .environment(calendarState)
//                case .noteBooks:
//                    NotebooksListView(icloudSyncing: $icloudSyncing, usersState: notebooksListState, selectedNotebook: $selectedNotebookM)
////                        .environmentObject(notebooksListState)
////                        .onAppear {
////                            Task {
////                                await notebooksListState.loadData()
////                            }
////                        }
//                }
//            } else {
//                // no selection done
//                Text("NOT SELECTED")
//            }
//        } 
//    
    detail: {
        
        let selectedItem = SidebarItem(rawValue: sidebarItemSelected ?? SidebarItem.timeline.id)!
        switch selectedItem {
            
        case .timeline:
            TimelineDetailView(timelineDetailState: $timelineDetailState)
        case .notebooks:
            NotebooksListView(icloudSyncing: $icloudSyncing, usersState: notebooksListState, selectedNotebook: $selectedNotebookM)
        }
        
        
        
        
//            let selectedMode = Mode.getMode(id: selectedModeID ?? Mode.timeline.id)!
//            switch selectedMode {
//            case .timeline:
////                if UIDevice.current.userInterfaceIdiom == .phone {
////                    EmptyView()
////                } else {
//                    let calendarType = calendarState.calenderType
//                    switch calendarType {
//                    case .day:
//                        
////                        Text("\(calendarState.dayDate.date.string(format: "mm-dd-yy"))")
////                        NotebookEditorView(notebookM: selectedNotebookM!, editorState: editorState)
////                        DayDetailView()
//                        DayDetailView(navigationSplitViewVisibility: $navigationSplitViewVisibility)
//                            .navigationSplitViewStyle(.prominentDetail)
//                    case .week:
//                        WeekDetailView()
//                    case .month:
//                        MonthDetailView()
//                    }
//                    
////                }
//            case .noteBooks:
//                
//                
//                NotebooksListView(icloudSyncing: $icloudSyncing, usersState: notebooksListState, selectedNotebook: $selectedNotebookM)
//                
////                if selectedNotebookM != nil {
////                    // ** binding won't work here.
//////                    NotebookEditorView(listDisplayState: notebooksListState.listSourceType, notebookM: selectedNotebookM!, editorState: editorState, navigationSplitViewVisibility: $navigationSplitViewVisibility)
////                    
////                    if let notebook = NotebooksCache.shared.flatNotebooks[selectedNotebookM!.uuidString] {
////                        
////                        NotebookEditorView(listDisplayState: notebooksListState.listSourceType, notebookM: notebook, editorState: editorState, navigationSplitViewVisibility: $navigationSplitViewVisibility)
////                        
//////                        NotebookEditorView(notebookM: notebook, editorState: editorState)
////                    } else {
////                        Text("selcted")
////                    }
////                    
////                } else {
////                    Text("No notebook selected")
////                }
//                
//                
////                    .navigationTitle(selectedUser?.name ?? "")
//            case .settings:
//                Text("asdf")
//            }
        }
    }
       
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

