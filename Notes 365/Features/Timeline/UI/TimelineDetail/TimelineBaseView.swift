//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineBaseView: View {
    @Binding var state: TimelineBaseViewState
    @Binding var horizontalCalendarViewState: HorizontalCalendarViewState
    @State private var loadedFirstTime = false
    @State private var showCalendar = false
    @State private var calendarDate = DateTime.now()
    
    var body: some View {
        VStack {
            HorizontalCalendarView(state: $horizontalCalendarViewState, selectedDates: $state.selectedDates)
            ScrollView(.vertical, showsIndicators: false) {
                RangeTimelineView(selectedDates: $state.selectedDates)
            }
            .listStyle(PlainListStyle())
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: calendarDate, { oldValue, newValue in
            state.selectedDates = [newValue]
            horizontalCalendarViewState.selectedDateRange = nil
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCalendar = true
                } label: {
                    Image(systemName: "calendar")
                }
                .popover(isPresented: $showCalendar, content: {
                    CalendarView(calendarDate: $calendarDate)
                })
            }
        }
        
    }
}

struct CalendarView: View {
    @Binding var calendarDate: Date
    
    var body: some View {
        VStack {
            DatePicker(
                   "Start Date",
                   selection: $calendarDate,
                   displayedComponents: [.date]
               )
               .datePickerStyle(.graphical)
               .padding()
            Spacer()
        }
        .frame(minWidth: 420)
    }
}

enum TimelineDateRangeType {
    case today
    case previousSevenDays
    case month
}

struct TimelineDateRange: Identifiable {
    let id = UUID()
    let title: String
    let type: TimelineDateRangeType
    let date: Date
}

extension TimelineDateRange: Equatable {
    
}


struct LoadingStatusMessageView: View {
    @Binding var timelineDetailState: TimelineBaseViewState
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

//struct LoadMoreView: View {
//    @Binding var timelineDetailState: TimelineDetailState
//    var body: some View {
//        if timelineDetailState.canLoadMore {
//            VStack {
//                HStack {
//                    Spacer()
//                    Text("Loading.. in (timeline detail)")
//                    Spacer()
//                }
//                .progressViewStyle(CircularProgressViewStyle())
//                .foregroundStyle(.gray)
//                .frame(height: 80)
//                .onAppear {
//                    print("load more appear")
//                    timelineDetailState.tryLoadMore()
//                }
//            }
//            .listRowSeparator(.hidden)
//        }
//    }
//}

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
