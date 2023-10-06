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
    @State private var calendarState = CalendarState()
    
    
    var body: some View {
        VStack {
            MonthDetailView(timelineDetailState: timelineDetailState)
        }
        .onAppear {
//            if timelineDetailState.isFirstAppear {
//                timelineDetailState.isFirstAppear = false
                
                
                timelineDetailState.timelineBusiness.modelContext = modelContext
                timelineDetailState.timelineBusiness.updateTodayTimelineIndex()
                // load timelineindex
            // day
            timelineDetailState.fetchDayTimelineIndexList(calendarState.dayDate.date)
//                timelineDetailState.fetchAllTimelineIndexList()
//            }
            
            
//                // load first notebook
//
//
//                timelineDetailState.readData(timelineDetailState.selectedDate)
        }
        .onDisappear(perform: {
            timelineDetailState.clearDisplay()
        })
//        .onChange(of: calendarState.calenderType, { oldValue, newValue in
//            print("calenderType: ", newValue)
//            
////            calendarState.monthDate
//        })
        .onChange(of: calendarState.dayDate, { oldValue, newValue in
            // day
            timelineDetailState.fetchDayTimelineIndexList(newValue.date)
        })
        .onChange(of: calendarState.weekDate, { oldValue, newValue in
            // week
            timelineDetailState.fetchWeekTimelineIndexList(newValue.start)
        })
        .onChange(of: calendarState.monthDate, { oldValue, newValue in
            // month
            timelineDetailState.fetchMonthTimelineIndexList(newValue.start)
        })
        .toolbar {
            // menu options
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
////                    timelineDetailState.setToday()
//                    
//                    timelineDetailState.timelineBusiness.setAsBeforeDay()
//                } label: {
//                    Text("set as before day")
//                }
//                .foregroundColor(.primary)
//            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
//                    timelineDetailState.setToday()
                    
//                    timelineDetailState.timelineBusiness.setAsBeforeDay()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
//                    timelineDetailState.setToday()
                    
//                    timelineDetailState.timelineBusiness.setAsBeforeDay()
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
                    TimelineCalendarView()
                        .environment(calendarState)
                        .frame(width: 280)
                        .padding()
                }
            }
        }
        
    }
}


struct MonthDetailView: View {
    
    @Namespace var bottomID
    @Environment (\.modelContext) var modelContext
    @Bindable var timelineDetailState: TimelineDetailState
    
    // loading
    @State var isLoadingMore = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach($timelineDetailState.timelineIndexList, id: \.id) { $timelineIndex in
                        // for each day
                        MonthSectionView(timelineState: timelineDetailState, timelineIndex: $timelineIndex)
                            .listRowSeparator(.hidden)
                            .id(timelineIndex.id)
                    }
                    
//                    if timelineDetailState.canLoadMore && timelineDetailState.dayChangesList.count > 0 {
//                        HStack {
//                            Spacer()
//                            Text("Loading..")
//                                .onAppear {
//                                    if isLoadingMore == false {
//                                        isLoadingMore = true
//                                        Task {
//                                            // Delay the task by 1 second:
////                                            try await Task.sleep(nanoseconds: 5_000_000_000)
//                                             timelineDetailState.fetchPreviousDate()
//                                            
//                                            // Perform our operation
//                                            isLoadingMore = false
//                                        }
//                                    }
//                                }
//                            Spacer()
//                        }
//                    }
                    
                    HStack {
                        Spacer()
                        Text(timelineDetailState.currentState.message)
                            .listRowSeparator(.hidden)
                            .fontWeight(.ultraLight)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
//                .onChange(of: timelineDetailState.selectedDate, { oldValue, newValue in
//                    // get id for the selected date
//                    let selectedDayIndex = timelineDetailState.timelineIndexList.first { dayIndex in
//                        dayIndex.date <= newValue
//                    }
//                    
//                    guard let selectedDayIndex = selectedDayIndex else { return }
//                    
//                    withAnimation {
//                        proxy.scrollTo(selectedDayIndex.id, anchor: .top)
//                    }
////                    print(selectedDayIndex.dateString)
//                    
//                })
            }
//            .onChange(of: timelineDetailState.selectedDate, { oldValue, newValue in
//
////                Task {
////                    timelineDetailState.generatorTask?.cancel()
////                    DispatchQueue.main.async {
////                        timelineDetailState.currentState = .loading
////                        timelineDetailState.dayChangesList.removeAll()
////                    }
////                    
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
////                        // your code here
////                        timelineDetailState.readData(newValue)
////                    }
////                }
//            })
            .onDisappear {
//                timelineDetailState.generatorTask?.cancel()
            }
        }
        .toolbar {
//            ScaleFontView(theme: $theme)
        }
    }
    
    static func getMonthStartEndDates(date: Date) -> (Date, Date) {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: date)
        else { fatalError() }
        
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        
        return (startDate, endDate)
    }
    
}

// each day
struct MonthSectionView: View {
    
    var timelineState: TimelineDetailState
    @Binding var timelineIndex: DayIndex
    @State var loadingSpinnerTask: Task<(), Error>?
    @State var isVisible = false
    
    var isDataLoaded: Bool {
        timelineIndex.dayChanges != nil
    }
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Text(timelineIndex.formattedDate)
                    .listRowSeparator(.hidden)
                    .padding(.horizontal)
//                    .font(.title)
                    .font(.largeTitle)
                    .padding(.top, 30)
            }
            
            if isDataLoaded {
                DayTimelineTwoView(timelineList: $timelineIndex.dayChanges.notes)
            } else {
                HStack {
                    Spacer()
                    Text("Loading..")
                    Spacer()
                }
                .frame(idealHeight: 800)
            }
        }
        .onAppear {
            isVisible = true
            
//            if loadingSpinnerTask != nil {
//                return
//            }
            
            loadingSpinnerTask = Task {
                
                try await Task.sleep(nanoseconds: 2_000_000_000)
//                guard let loadingSpinnerTask = loadingSpinnerTask, !loadingSpinnerTask.isCancelled else {
//                    print("afterSleep: isCancelled: true", timelineIndex.dateString)
//                    return }
//                
//                print("afterSleep: isCancelled: false", timelineIndex.dateString)
                timelineIndex.loadTimelineContent(timelineState.timelineBusiness)
            }
//                timelineIndex.loadTimelineContent(timelineState.timelineBusiness)
        }
//        .onDisappear {
//            isVisible = false
//            loadingSpinnerTask?.cancel()
//            loadingSpinnerTask = nil
////            print("onDisappear: cancelled", timelineIndex.dateString)
//        }
        
//        Section {
//            
//            
//        } header: {
            
//        }
        
        
        
//        // day header
//        
//        if timelineIndex.dayChanges == nil {
//            
//            
//        } else {
//            
//            
//
//        }
        
        
//        Section(dayTimeline.date.formatted(date: .complete, time: .omitted)) {
//            DayTimelineTwoView(timelineList: $dayTimeline.notes)
//        }
        
//        VStack {
//            HStack {
//                Spacer()
//                if UIDevice.current.userInterfaceIdiom == .phone {
//                    Text(dayTimeline.date.formatted(date: .abbreviated, time: .omitted))
//                        .listRowSeparator(.hidden)
//                        .padding(.horizontal)
//                        .font(.largeTitle)
//                        .padding(.top, 30)
//                } else {
//                    Text(dayTimeline.date.formatted(date: .complete, time: .omitted))
//                        .listRowSeparator(.hidden)
//                        .padding(.horizontal)
//                        .font(.largeTitle)
//                        .padding(.top, 30)
//                }
//            }
//            DayTimelineTwoView(timelineList: $dayTimeline.notes)
//        }
//        .id(dayTimeline.notes.first!.id)
    }
}

fileprivate struct DayTimelineTwoView: View {
    
    @Binding var timelineList: [Timeline]
    
    var body: some View {
        ForEach($timelineList) { $noteChange in
            VStack {
                NoteChangeHeadingView(noteChange: noteChange, deleteTimeline: Binding.constant(nil))
//                    .id(noteChange.id)
                HStack {
                    
                    ReadOnlyMarkDownViewTwo(timeline: $noteChange)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                    Spacer()
                }
            }
            
        }
    }
}

