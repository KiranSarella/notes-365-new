//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineDetailView: View {
    
    @State private var timelineDetailState = TimelineDetailState()
    @State private var isShowingCalendar = false
    
    var body: some View {
        VStack {
            MonthDetailView(timelineDetailState: timelineDetailState)
        }
        .toolbar {
            // menu options
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    timelineDetailState.setToday()
                } label: {
                    Text("Today")
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
                    TimelineCalendarView(selectedDate: $timelineDetailState.selectedDate)
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
                    ForEach($timelineDetailState.dayChangesList, id: \.id) { $dayTimeline in
                        // for each day
                        MonthSectionView(date: timelineDetailState.selectedDate, dayTimeline: $dayTimeline, width: 0)
                            .id(dayTimeline.notes.first?.id)
                            .listRowSeparator(.hidden)
                    }
                    
                    if timelineDetailState.canLoadMore && timelineDetailState.dayChangesList.count > 0 {
                        HStack {
                            Spacer()
                            Text("Loading..")
                                .onAppear {
                                    if isLoadingMore == false {
                                        isLoadingMore = true
                                        Task {
                                            // Delay the task by 1 second:
//                                            try await Task.sleep(nanoseconds: 5_000_000_000)
                                             timelineDetailState.fetchPreviousDate()
                                            
                                            // Perform our operation
                                            isLoadingMore = false
                                        }
                                    }
                                }
                            Spacer()
                        }
                    }
                    
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
            }
            .onAppear {
                timelineDetailState.timelineBusiness.modelContext = modelContext
                timelineDetailState.readData(timelineDetailState.selectedDate)
            }
            .onChange(of: timelineDetailState.selectedDate, { oldValue, newValue in
                Task {
                    timelineDetailState.generatorTask?.cancel()
                    DispatchQueue.main.async {
                        timelineDetailState.currentState = .loading
                        timelineDetailState.dayChangesList.removeAll()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // your code here
                        timelineDetailState.readData(newValue)
                    }
                }
            })
            .onDisappear {
                timelineDetailState.generatorTask?.cancel()
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
    
    var date: Date
    @Binding var dayTimeline: DayChanges
    var width: CGFloat
    
    var body: some View {
        
        // day header
        VStack {
            HStack {
                Spacer()
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Text(dayTimeline.date.formatted(date: .abbreviated, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                } else {
                    Text(dayTimeline.date.formatted(date: .complete, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                }
            }
            
            DayTimelineTwoView(timelineList: $dayTimeline.notes)
        }
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

