//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedModeID: Mode.ID?
    // timeline related
    @StateObject var calendarState = CalendarState.shared
    // notebooks related
    @State private var selectedUser: NotebookM?
    @State private var userSelectionState: UserSelectionState?
    @State private var userSelectionStateDB: UserSelectionState?
    @StateObject var usersState = NotebooksListState.shared
    
    var body: some View {
        NavigationSplitView {
            // navigation headings
            List(Mode.allCases, selection: $selectedModeID) { selectedMode in
                HStack(spacing: 0) {
                    Image(systemName: selectedMode.image)
                    Text(selectedMode.name)
                        .padding(.horizontal)
                }
            }
        } content: {
            // calender and notebooks list
            if let selectedMode = Mode.getMode(id: selectedModeID) {
                switch selectedMode {
                case .timeline:
                    TimelineSidebarView()
                        .environmentObject(calendarState)
                case .noteBooks:
                    UsersSidebarView(selectedMode: Binding.constant(selectedMode), userSelectionState: $userSelectionState, userSelectionStateDB: $userSelectionStateDB, selectedUser: $selectedUser)
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
            if let selectedMode = Mode.getMode(id: selectedModeID) {
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
                    if userSelectionState != nil {
                        NotebookEditorView(userSelectionState: userSelectionState!,
                                         selectedMode: $selectedModeID)
                    }
                }
            }
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
