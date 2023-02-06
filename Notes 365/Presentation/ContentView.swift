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
//                .scrollDisabled(true)
                .navigationTitle("Notes 365")
                
                
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
                    SettingsView_iPadOS(showModel: $showSettings)
                }
                
                #endif
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
//
//                    VStack {
//
//                        NavigationLink {
//                            // destination view here
//                            Text("Month detail....")
//                        } label: {
//                            Text("Month")
//                        }
//
//                        Button {
//                            selectedCalenderType = CalendarType.day.id
//                            selectedCalender = .day
//                        } label: {
//                            NavigationLink("day nav", value: selectedCalender)
//                        }
//                        .navigationDestination(for: CalendarType.self) { calType in
//                            switch calType {
//                            case .day:
//                                Text("day detail")
//                            case .week:
//                                Text("week detail")
//                                //                    WeekDetailView()
//                            case .month:
//                                Text("month detail")
//                                //                    MonthDetailView()
//                            }
//                        }
//
//                        Button {
//                            selectedCalender = CalendarType.week
//
//                            NavigationLink("day nav", value: selectedCalender)
//
//                        } label: {
//                            Text("Week")
//                        }
//
//                    }
//
//
                    
//                    Button {
//                        calendarState.calenderType = CalendarType.day
//                    } label: {
//                        Text("day")
//                    }
//
                   
                    
//                    List(CalendarType.allCases, selection: $selectedCalender) { type in
//
//                        Text(type.name)
//
////                        Button {
////                            calendarState.calenderType = type
////                        } label: {
////                            Text(type.name)
////                        }
//
//                    }
//                    .onChange(of: selectedCalender) { newValue in
//                        print(newValue)
//                        if newValue != nil {
//                            calendarState.calenderType = newValue!
//                        }
//
//                    }
                    
//                    Picker("", selection: $selectedCalender) {
//                        ForEach(CalendarType.allCases, id: \.self) { calendarType in
//                            Text(calendarType.name).tag(calendarType)
//                        }
//                    }
//                    .onChange(of: selectedCalender, perform: { newValue in
//                        print(newValue)
//                    })
//                    .pickerStyle(SegmentedPickerStyle())
                    

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
#if os(macOS)
                let calendarType = calendarState.calenderType
                switch calendarType {
                case .day:
                    DayDetailView()
                case .week:
                    WeekDetailView()
                case .month:
                    MonthDetailView()
                }
#else
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
#endif
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

struct DayDetailTest: View {
    
    @Binding var selectedCalender: CalendarType?
    
    var body: some View {
        if let cal = selectedCalender {
            Text(cal.name)
        } else {
            Text("SELECTION REQ...")
        }
    }
}
