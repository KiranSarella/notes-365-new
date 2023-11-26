//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineDetailView: View {
    @Binding var state: TimelineDetailState
    @State private var isShowingCalendar = false
    @State private var loadedFirstTime = false
    
    var body: some View {
        GeometryReader { geometry in
         
        VStack {
            HorizontalCalendarView(selectedDates: $state.selectedDates)
            ScrollView(.vertical, showsIndicators: false) {
//                TimelinecurrentDateHeaderView(timelineDetailState: $timelineDetailState)
//                LoadingStatusMessageView(timelineDetailState: $timelineDetailState)
                RangeTimelineView(selectedDates: $state.selectedDates)
//                LoadMoreView(timelineDetailState: $timelineDetailState)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
        }
        .onAppear {
//            timelineDetailState.loadDayContent()
//            if loadedFirstTime == false {
//                loadedFirstTime = true
//                timelineDetailState.startReloadingContent()
//            }
        }
        .onDisappear(perform: {
//            timelineDetailState.clearDisplay()
        })
        .onChange(of: state.selectedDates, { oldValue, newValue in
            print(newValue)
//            state.startReloadingContent()
        })
        .toolbar {
            // menu options
//            ToolbarItem(placement: .topBarTrailing) {
//                    HorizontalCalendarView()
//                    .frame(width: geometry.size.width > 100 ? geometry.size.width - 100 : 600)
//                
//            }
            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    timelineDetailState.calendarState.previousStep()
//                } label: {
//                    Image(systemName: "chevron.left")
//                }
//                .foregroundColor(.primary)
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    timelineDetailState.calendarState.nextStep()
//                } label: {
//                    Image(systemName: "chevron.right")
//                }
//                .foregroundColor(.primary)
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    isShowingCalendar = true
//                } label: {
//                    Image(systemName: "calendar")
//                }
//                .foregroundColor(.primary)
//                .popover(isPresented: $isShowingCalendar) {
//                    TimelineCalendarView(timelineCalendarState: $timelineDetailState.calendarState)
//                        .frame(minWidth: 320)
//                        .padding()
//                }
//            }
        }
            
        }
    }
}

struct HorizontalCalendarView: View {
    
    @Binding var selectedDates: [Date]
    let buttons = ["Today", "Previous 7 Days", "November", "October"]
    
//    ["Today", "Previous 7 Days", "Previous 30 Days", "October", "September", "August", "July", "June", "May 23", "April 23", "Janurary", "December 22", "November 22", "October 22"]
    
    @State private var selected: String?
    
    func isSelected(input: String) -> Bool {
        guard let selected = selected else { return false }
        return selected == input
    }
    
//    func getButtonStyle(_ input: String) -> any PrimitiveButtonStyle {
//        guard let selected = selected else { return BorderedButtonStyle() }
//        if selected == input {
//            return BorderedProminentButtonStyle()
//        } else {
//            return BorderedButtonStyle()
//        }
//    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(buttons, id: \.self) { button in
                        VStack {
                            if isSelected(input: button) {
                                Button {
                                    
                                } label: {
                                    Text(button)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    selected = button
                                    if button == "Today" {
                                        selectedDates = [Date()]
                                    } else if button == "Previous 7 Days" {
                                        var today = Date()
                                        var dates = [Date]()
                                        for _ in 0..<7 {
                                            today = today.dayBefore
                                            dates.append(today)
                                        }
                                        selectedDates = dates
                                    } else {
                                        selectedDates = Date().getDaysOfMonth()
                                    }
                                } label: {
                                    Text(button)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(5)
                        .id(button)
                    }
                }
                .padding(.horizontal)
//                .buttonStyle(.borderedProminent)
//                .background(Color.white)
            }.onAppear {
                selected = buttons.first
            }
        }

    }
}

struct TimelinecurrentDateHeaderView: View {
    @Binding var timelineDetailState: TimelineDetailState
    var body: some View {
        // header
        VStack {
            // day/week/month header view
            switch timelineDetailState.calendarState {
            case .day(let dayDate):
                // header view
                HStack {
                    Spacer()
                    Text(dayDate.formattedDate)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                if timelineDetailState.currentState != .data {
                    Text(dayDate.date.string(withFormat: "EEEE, d MMMM"))
                        .font(.subheadline)
                        .listRowSeparator(.hidden)
                }
            case .week(let weekDate):
                // header view
                HStack {
                    Spacer()
                    Text(weekDate.weekNumberHeading)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.heavy)
                    Spacer()
                }
            case .month(let monthDate):
                HStack {
                    Spacer()
                    Text(monthDate.start.string(format: "MMMM, YYYY"))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.heavy)
                    Spacer()
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct LoadingStatusMessageView: View {
    @Binding var timelineDetailState: TimelineDetailState
    var body: some View {
        // loading status message
        if timelineDetailState.currentState != .data {
            HStack {
                Spacer()
                Text(timelineDetailState.currentState.message)
                    .listRowSeparator(.hidden)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                Spacer()
            }
            .frame(height: 100)
            .listRowSeparator(.hidden)
        }
    }
}

struct LoadMoreView: View {
    @Binding var timelineDetailState: TimelineDetailState
    var body: some View {
        if timelineDetailState.canLoadMore {
            VStack {
                HStack {
                    Spacer()
                    Text("Loading..")
                    Spacer()
                }
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundStyle(.gray)
                .frame(height: 80)
                .onAppear {
                    print("load more appear")
                    timelineDetailState.tryLoadMore()
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}

extension Date {
    func startOfMonth() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps)!
    }
    
    func endOfMonth() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        let date = cal.date(from: comps)!
        let lastDayOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: date)!
        return lastDayOfMonth
    }
    
    func getDaysOfMonth() -> [Date] {
        
        //get the current Calendar for our calculations
        let cal = Calendar.current
        //get the days in the month as a range, e.g. 1..<32 for March
        let monthRange = cal.range(of: .day, in: .month, for: self)!
        //get first day of the month
        let comps = cal.dateComponents([.year, .month], from: self)
        //start with the first day
        //building a date from just a year and a month gets us day 1
        var date = cal.date(from: comps)!
        
        //somewhere to store our output
        var dates: [Date] = []
        //loop thru the days of the month
        for _ in monthRange {
            //add to our output array...
            dates.append(date)
            //and increment the day
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }
}
