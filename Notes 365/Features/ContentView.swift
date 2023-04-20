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
                        
                        statusMessage = "checking iCloud settings"
                        try chooseEnv.setEnviromment(with: .cloud)
                        statusMessage = "moving existing data to iCloud"
#if targetEnvironment(macCatalyst)
                        await chooseEnv.checkOldDataSync()
#endif
                        // old data compatability
                        /*
                         if cloud folder is empty
                         - new - first time user
                         - new - new device - have to pull from cloud
                         - local might contain old data
                         
                         copy from local to cloud folder and while doing convert to new folder structures.
                         */
                        
                        statusMessage = "iCloud sync.."
                        
                        chooseEnv.downloaodCloudDocuments(completion: {
                            // do any operations
                            chooseEnv.enableConfigured()
                        })
                        // do any operations
//                        chooseEnv.enableConfigured()
                        
                        // clean base version
                        TodayVersionBusiness.cleanBaseVersionIfNeeded()
                        
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
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var chooseEnv: ChooseEnvironment
    
    @State private var showSettings = false
    @State private var icloudSyncing = false
    
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
    
    private var todayVersionSync = TodayVersionSync(basePathURL: EnvironmentState.shared.basePathURL)
    
    
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
                            icloudSyncing = true
                            chooseEnv.downloaodCloudDocuments(completion: {
                                // do any operations
                                icloudSyncing = false
                            })
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
            }
            .onChange(of: colorScheme) { newValue in
                ThemeState.shared.colorScheme = newValue
            }
            
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
                if UIDevice.current.userInterfaceIdiom == .phone {
                    EmptyView()
                } else {
                    let calendarType = calendarState.calenderType
                    switch calendarType {
                    case .day:
                        DayDetailView()
                    case .week:
                        WeekDetailView()
                    case .month:
                        MonthDetailView()
                    }
                }
            case .noteBooks:
                
                if selectedNotebookM != nil {
                    NotebookEditorView(notebookM: Binding($selectedNotebookM)!, editorState: editorState)
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

