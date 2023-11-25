//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineDetailView: View {
    @Binding var timelineDetailState: TimelineDetailState
    @State private var isShowingCalendar = false
    @State private var loadedFirstTime = false
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                TimelinecurrentDateHeaderView(timelineDetailState: $timelineDetailState)
                LoadingStatusMessageView(timelineDetailState: $timelineDetailState)
                DayChangesView(date: Date(), timelines: $timelineDetailState.timelines, dayState: $timelineDetailState)
                    .listRowSeparator(.hidden)
            
//                ForEach($timelineDetailState.dayIndexs) { $day in
//                    DayChangesView(date: day.date, timelines: $day.timelines, dayState: $timelineDetailState)
//                        .listRowSeparator(.hidden)
//                }
                LoadMoreView(timelineDetailState: $timelineDetailState)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            timelineDetailState.loadDayContent()
//            if loadedFirstTime == false {
//                loadedFirstTime = true
//                timelineDetailState.startReloadingContent()
//            }
        }
        .onDisappear(perform: {
            timelineDetailState.clearDisplay()
        })
        .onChange(of: timelineDetailState.calendarState, { oldValue, newValue in
            timelineDetailState.startReloadingContent()
        })
        .toolbar {
            // menu options
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    timelineDetailState.calendarState.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    timelineDetailState.calendarState.nextStep()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingCalendar = true
                } label: {
                    Image(systemName: "calendar")
                }
                .foregroundColor(.primary)
                .popover(isPresented: $isShowingCalendar) {
                    TimelineCalendarView(timelineCalendarState: $timelineDetailState.calendarState)
                        .frame(minWidth: 320)
                        .padding()
                }
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
