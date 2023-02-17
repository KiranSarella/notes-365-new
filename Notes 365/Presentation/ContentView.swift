//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentWrapperView: View {
    
    var chooseEnv = ChooseEnvironment()
    
    @State private var didError = false
    @State private var errorDetail: Error?
    @State private var showRefresh = false
    
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
                Text("Loading..")
                    .task {
                        do {
                            try chooseEnv.setEnviromment(with: .cloud)
                            
                            // async sync icloud data on first time
                            
                            
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
        }
    }
}


struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showSettings = false
    
    @State private var selectedModeID: Mode.ID? = Mode.timeline.id
    // timeline related
    @ObservedObject var calendarState = CalendarState.shared
    // notebooks related
    @State private var selectedUser: NotebookM?
    @ObservedObject var usersState = NotebooksListState.shared
    
    @State var selectedCalenderType: CalendarType.ID? = CalendarType.day.id
    
    @State var selectedCalender: CalendarType? = CalendarType.day
    
    @State var showDetail = false
    
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
                // show settings option
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "gearshape")
                            Text("Settings")
                                .padding(.horizontal)
                        }.padding(.horizontal)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .sheet(isPresented: $showSettings) {
                    SettingsView_iPadOS(showModel: $showSettings)
                }
            }
            .frame(minWidth: 160)
                .background(.regularMaterial)
                .onAppear {
                    ThemeState.shared.colorScheme = colorScheme
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
                    NotebooksSidebarView(selectedNotebook: $selectedUser)
                        .environmentObject(usersState)
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
                NotebookEditorView(notebookM: $selectedUser)
                    .navigationTitle(selectedUser?.name ?? "")
            }
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

