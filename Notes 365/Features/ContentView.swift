//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentWrapperView: View {
    
    @StateObject var chooseEnv = ChooseEnvironment()
    
    @State private var didError = false
    @State private var errorDetail: Error?
    @State private var showRefresh = false
    
    @State private var statusMessage = "Loading.."
    
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
                        TodayVersionBusiness.cleanBaseVersionIfNeeded()
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
                .environmentObject(chooseEnv)
        }
    }
}


struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var chooseEnv: ChooseEnvironment
    
    @State private var showSettings = false
    @State private var icloudSyncing = false
    
//    @State private var notesListSyncing = false
//    @State private var notesContentSyncing = false
    
    @State private var selectedModeID: Mode.ID? = Mode.timeline.id
    // timeline related
    @ObservedObject var calendarState = CalendarState.shared
    // notebooks related
    @State private var selectedNotebookM: NotebookM?
    @ObservedObject var notebooksListState = NotebooksListState.shared
    
    @State var selectedCalenderType: CalendarType.ID? = CalendarType.day.id
    
    @State var selectedCalender: CalendarType? = CalendarType.day
    
    @State var showDetail = false
    
    @StateObject private var editorState = NotebookEditorState()
    
    private var notebooksListSync = NotebooksListSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var timelineSync = TimelineSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var todayVersionSync = TodayVersionSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var notebooksContentSync = NotebooksContentSync(basePathURL: EnvironmentState.shared.basePathURL)
    private var deletedListSync = DeletedListSync(basePathURL: EnvironmentState.shared.basePathURL)
    
    var bottomViewBackgroundColor: Color {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return Color(uiColor: UIColor.systemGroupedBackground)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return Color(uiColor: UIColor.secondarySystemBackground)
        }
        
        return Color(uiColor: UIColor.systemGroupedBackground)
    }
    
    var body: some View {
        NavigationSplitView {
            // navigation headings
            VStack {
                List(Mode.allCases, selection: $selectedModeID) { selectedMode in
                    HStack(spacing: 0) {
                        Image(systemName: selectedMode.image)
                        Text(selectedMode.name)
                            .padding(.horizontal)
                    }
                }
                .navigationTitle("Notes 365")
                Spacer()
                // bottom view - settings option
                HStack {
                    VStack {
                        Button {
                            // do sync
                            // plist
                            notebooksListSync.initialGatheringSync()
                            // notebooks
                            notebooksContentSync.initialGatheringSync()
                            // timeline
                            timelineSync.initialGatheringSync()
                            // today base version
                            todayVersionSync.initialGatheringSync()
                            // deleted list
                            deletedListSync.initialGatheringSync()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("iCloud Sync")
                                    .padding(.horizontal, 6)
                                
                                ProgressView()
                                    .opacity(icloudSyncing ? 1 : 0)
                                
                            }.padding(4)
                            Spacer()
                        }
                        .help("Sync with iCloud")
                        
                        Button {
                            showSettings = true
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("Settings")
                                    .padding(.horizontal, 6)
                            }.padding(4)
                            Spacer()
                        }
                        .help("Settings")
                    }
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showSettings) {
                    SettingsView_iPadOS(showModel: $showSettings)
                }
            }
            .frame(minWidth: 180)
            .background(bottomViewBackgroundColor)
            .onAppear {
                ThemeState.shared.colorScheme = colorScheme
//                    // do sync
//                    icloudSyncing = true
//                    chooseEnv.downloaodCloudDocuments(completion: {
//                        // do any operations
//                        icloudSyncing = false
//                    })
                
                notebooksListSync.isSyncingStarted = {
                    self.icloudSyncing = true
                }
                
                notebooksListSync.isSyncingCompleted = {
                    self.icloudSyncing = false
                }
                
//                notebooksContentSync.isSyncingStarted = {
//                    if self.icloudSyncing == false {
//                        self.icloudSyncing = true
//                    }
//                }
//
//                notebooksContentSync.isSyncingCompleted = {
//
//                }
            }
            .onChange(of: colorScheme) { newValue in
                ThemeState.shared.colorScheme = newValue
            }
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
            
        } content: {
            // calender and notebooks list
            if let selectedMode = Mode.getMode(id: selectedModeID) {
                switch selectedMode {
                case .timeline:
                    TimelineSidebarView(calendarID: $selectedCalenderType)
                        .environmentObject(calendarState)
                case .noteBooks:
                    NotebooksListView(icloudSyncing: $icloudSyncing, selectedNotebook: $selectedNotebookM)
                        .environmentObject(notebooksListState)
//                        .onAppear {
//                            Task {
//                                await notebooksListState.loadData()
//                            }
//                        }
                }
            } else {
                // no selection done
                Text("NOT SELECTED")
            }
        } detail: {
            let selectedMode = Mode.getMode(id: selectedModeID ?? Mode.timeline.id)!
            switch selectedMode {
            case .timeline:
//                if UIDevice.current.userInterfaceIdiom == .phone {
//                    EmptyView()
//                } else {
                    let calendarType = calendarState.calenderType
                    switch calendarType {
                    case .day:
                        
//                        Text("\(calendarState.dayDate.date.string(format: "mm-dd-yy"))")
//                        NotebookEditorView(notebookM: selectedNotebookM!, editorState: editorState)
                        DayDetailView()
                    case .week:
                        WeekDetailView()
                    case .month:
                        MonthDetailView()
                    }
//                }
            case .noteBooks:
                
                if selectedNotebookM != nil {
                    // ** binding won't work here.
                    NotebookEditorView(listDisplayState: notebooksListState.listSourceType, notebookM: selectedNotebookM!, editorState: editorState)
                } else {
                    Text("No notebook selected")
                }
                
                
//                    .navigationTitle(selectedUser?.name ?? "")
            }
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

