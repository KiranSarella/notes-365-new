//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Binding var timelineDetailState: TimelineDetailState
    @State private var isShowingCalendar = false
    @State private var loadedFirstTime = false
    
//    var calendarState: TimelineCalendarState {
//        timelineDetailState.calendarState
//    }
    
    var body: some View {
        VStack {
            List {
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
                
                // contents
                ForEach($timelineDetailState.dayIndexs) { $day in
                    DayChangesView(date: day.date, timelines: $day.timelines, dayState: $timelineDetailState)
                        .listRowSeparator(.hidden)
                }
                
                // load more
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
            .listStyle(PlainListStyle())
        }
        .onAppear {
            
            if loadedFirstTime == false {
                loadedFirstTime = true
//                
//                timelineDetailState.timelineBusiness.modelContext = modelContext
//                timelineDetailState.timelineBusiness.updateTodayTimelineIndex()
//                
                timelineDetailState.startReloadingContent()
            }
        }
        .onDisappear(perform: {
            timelineDetailState.clearDisplay()
        })
        .onChange(of: timelineDetailState.calendarState, { oldValue, newValue in
            timelineDetailState.startReloadingContent()
        })
//        
//        .onChange(of: calendarState.dayDate, { oldValue, newValue in
//            // day
//            timelineDetailState.startReloadingContent()
//        })
//        .onChange(of: calendarState.weekDate, { oldValue, newValue in
//            // week
//            timelineDetailState.startReloadingContent()
//        })
//        .onChange(of: calendarState.monthDate, { oldValue, newValue in
//            // month
//            timelineDetailState.startReloadingContent()
//        })
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

