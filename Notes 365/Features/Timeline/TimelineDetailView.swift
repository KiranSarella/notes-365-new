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
//    @State private var calendarState = CalendarState()
    
    @State private var loadedFirstTime = false
    @State var isFirstTimeAppear = true
    
    var calendarState: CalendarState {
        timelineDetailState.calendarState
    }
    
    var body: some View {
        VStack {
            List {
                // header
                VStack {
                    // day/week/month header view
                    switch calendarState.calenderType {
                    case .day:
                        // header view
                        HStack {
                            Spacer()
                            Text(calendarState.dayDate.formattedDate)
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        if timelineDetailState.currentState != .data {
                            Text(calendarState.dayDate.date.string(withFormat: "EEEE, d MMMM"))
                                .font(.callout)
                                .padding(0)
                                .listRowSeparator(.hidden)
                        }
                    case .week:
                        // header view
                        HStack {
                            Spacer()
                            Text(calendarState.weekDate.weekNumberHeading)
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                    case .month:
                        HStack {
                            Spacer()
                            Text(calendarState.monthDate.start.string(format: "MMMM, YYYY"))
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
                ForEach($timelineDetailState.days) { $day in
                    DayDetailView(date: day.date, timelines: $day.timelines, dayState: $timelineDetailState)
                        .listRowSeparator(.hidden)
                }
                
                // load more
                if timelineDetailState.canLoadMore {
                    VStack {
                        VStack {
                            Text("Load more")
                        }
                        .background(Color.green)
                        .frame(height: 50)
                        .onAppear {
                            print("load more appear")
                            timelineDetailState.tryLoadMore()
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            
//            let calendarType = calendarState.calenderType
//            switch calendarType {
//            case .day:
//                
//                ForEach($timelineDetailState.days) { $day in
////                    DayDetailView(dayState: $timelineDetailState)
//                    DayDetailView(date: day.date, timelines: $day.timelines, dayState: $timelineDetailState)
//                }
//                
////                DayDetailView(dayState: $timelineDetailState)
//            case .week:
//                WeekDetailView(weekState: $timelineDetailState)
//            case .month:
////                MonthDetailView()
//                Text("month")
//            }
            
            
//            MonthDetailView(timelineDetailState: timelineDetailState, calendarState: calendarState)
        }
        .onAppear {
//            if timelineDetailState.isFirstAppear {
//                timelineDetailState.isFirstAppear = false
                
                
                timelineDetailState.timelineBusiness.modelContext = modelContext
                timelineDetailState.timelineBusiness.updateTodayTimelineIndex()
                // load timelineindex
            
            if loadedFirstTime == false {
                loadedFirstTime = true
                
                switch calendarState.calenderType {
                case .day:
                    Task {
                        timelineDetailState.generatorTask?.cancel()
                        timelineDetailState.clearDisplay()
                        DispatchQueue.main.async {
                            timelineDetailState.currentState = .loading
                            timelineDetailState.days.removeAll()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // your code here
                            timelineDetailState.readDayData(dayDate: calendarState.dayDate)
                        }
                    }
                case .week:
                    Task {
                        timelineDetailState.generatorTask?.cancel()
                        timelineDetailState.clearDisplay()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // your code here
                            timelineDetailState.readWeekData(weekDate: calendarState.weekDate)
                        }
                    }
                case .month:
                    Task {
                        timelineDetailState.generatorTask?.cancel()
                        timelineDetailState.clearDisplay()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // your code here
                            timelineDetailState.readMonthData(monthDate: calendarState.monthDate)
                        }
                    }
                }
            }
            
            // day
//            timelineDetailState.fetchDayTimelineIndexList(calendarState.dayDate.date)
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
        .onChange(of: calendarState.calenderType, { oldValue, newValue in
            print("calenderType: ", newValue)
            timelineDetailState.displayngCalendarType = newValue
//            calendarState.monthDate
        })
        .onChange(of: calendarState.dayDate, { oldValue, newValue in
            // day
            
//            timelineDetailState.readDayData(dayDate: newValue)
//            timelineDetailState.loadContent(.day, newValue.date)
            
            Task {
                timelineDetailState.generatorTask?.cancel()
                timelineDetailState.clearDisplay()
                DispatchQueue.main.async {
                    timelineDetailState.currentState = .loading
                    timelineDetailState.days.removeAll()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    timelineDetailState.readDayData(dayDate: newValue)
                }
            }
        })
        .onChange(of: calendarState.weekDate, { oldValue, newValue in
            // week
//            timelineDetailState.readWeekData(weekDate: newValue)
//            timelineDetailState.loadContent(.week, newValue.start)
            
            Task {
                timelineDetailState.generatorTask?.cancel()
                timelineDetailState.clearDisplay()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    timelineDetailState.readWeekData(weekDate: newValue)
                }
            }
        })
        .onChange(of: calendarState.monthDate, { oldValue, newValue in
            // month
//            timelineDetailState.loadContent(.month, newValue.start)
            Task {
                timelineDetailState.generatorTask?.cancel()
                timelineDetailState.clearDisplay()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    timelineDetailState.readMonthData(monthDate: newValue)
                }
            }
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
                    calendarState.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    calendarState.nextStep()
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
    @Bindable var calendarState: CalendarState
    
    // loading
    @State var isLoadingMore = false
    
    var body: some View {
        VStack(spacing: 0) {
//            ScrollViewReader { proxy in
                List {
                    
                    VStack {
                        // day/week/month header view
                        switch calendarState.calenderType {
                        case .day:
                            // header view
                            HStack {
                                Spacer()
                                Text(calendarState.dayDate.formattedDate)
                                    .listRowSeparator(.hidden)
                                    .padding(.horizontal)
                                    .font(.largeTitle)
                                    .fontDesign(.rounded)
                                    .fontWeight(.heavy)
                                Spacer()
                            }
                        case .week:
                            // header view
                            HStack {
                                Spacer()
                                Text(calendarState.weekDate.weekNumberHeading)
                                    .listRowSeparator(.hidden)
                                    .padding(.horizontal)
                                    .font(.largeTitle)
                                    .fontDesign(.rounded)
                                    .fontWeight(.heavy)
                                Spacer()
                            }
                        case .month:
                            HStack {
                                Spacer()
                                Text(calendarState.monthDate.start.string(format: "MMMM, YYYY"))
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
                    
                    
                    ForEach($timelineDetailState.days, id: \.id) { $timelineIndex in
                        // for each day
                        MonthSectionView(timelineState: timelineDetailState, timelineIndex: $timelineIndex, calenderType: calendarState.calenderType)
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
                            .fontWeight(.medium)
//                            .foregroundColor(.gray)
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
//            }
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
    
    var calenderType: CalendarType
    
    var isDataLoaded: Bool {
        timelineIndex.dayChanges != nil && timelineIndex.dayChanges.notes.count > 0
    }
    
    
    var body: some View {
        
        VStack {
            
            // header view
            switch calenderType {
            case .day:
                EmptyView()
            case .week:
                HStack {
                    Spacer()
//                    Text(timelineIndex.date.string(withFormat: "EEEE, d MMMM"))
                    Text(timelineIndex.formattedDate)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.title)
                        .padding(.top, 30)
                }
            case .month:
                HStack {
                    Spacer()
                    Text(timelineIndex.formattedDate)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.title)
                        .padding(.top, 30)
                }
            }
            
            
            
            if isDataLoaded {
                
                ForEach(timelineIndex.dayChanges.notes) { note in
                    Text(note.content ?? "")
                }
                
                
//                DayTimelineTwoView(timelineList: $timelineIndex.dayChanges.notes)
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
//            timelineIndex.loadTimelineContent(timelineState.timelineBusiness)
            
//            if loadingSpinnerTask != nil {
//                return
//            }
            
            
            
//            loadingSpinnerTask = Task {
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
////                guard let loadingSpinnerTask = loadingSpinnerTask, !loadingSpinnerTask.isCancelled else {
////                    print("afterSleep: isCancelled: true", timelineIndex.dateString)
////                    return }
////                
////                print("afterSleep: isCancelled: false", timelineIndex.dateString)
//                
//            }
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

