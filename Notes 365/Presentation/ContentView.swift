//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showSettings = false
    
    @State private var selectedModeID: Mode.ID? = Mode.timeline.id
    // timeline related
    @ObservedObject var calendarState = CalendarState.shared
    // notebooks related
    @State private var selectedUser: NotebookM?
    @State private var userSelectionState: SelectedNotebookInfo?
    @ObservedObject var usersState = NotebooksListState.shared
    
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
                }.scrollDisabled(true)
                
                #if os(iOS)
                
                Spacer()
                
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
                    SettingsView_iPadOS()
                }
                
                #endif
            }.background(.regularMaterial)
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
                    TimelineSidebarView()
                        .environmentObject(calendarState)
                case .noteBooks:
                    NotebooksSidebarView(selectedUser: $selectedUser)
                        .environmentObject(usersState)
                        .onChange(of: userSelectionState, perform: { newValue in
                            usersState.userSelectionStateTwo = newValue
                        })
                        
                }
            } else {
                // no selection done
                Text("NOT SELECTED")
            }
        } detail: {
            let selectedMode = Mode.getMode(id: selectedModeID!)!
            switch selectedMode {
            case .timeline:
                let calendarType = calendarState.calenderType
                switch calendarType {
                case .day:
                    DayDetailView(date: calendarState.selectedDate)
                case .week:
                    WeekDetailView()
                case .month:
                    MonthDetailView()
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
