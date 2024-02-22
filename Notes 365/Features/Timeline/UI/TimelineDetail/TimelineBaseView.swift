//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineBaseView: View {
    @Binding var path: NavigationPath
    @Binding var state: TimelineBaseViewState
    @Binding var horizontalCalendarViewState: HorizontalCalendarViewState
    @State private var loadedFirstTime = false
    @State private var showCalendar = false
    @State private var calendarDate = DateTime.now()
    @State var caldendarState = TimelineCalendarState.none
    @State var width: CGFloat = 0
//    @State var scrollViewHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometryProxy in
                VStack {
                    HorizontalCalendarView(state: $horizontalCalendarViewState, selectedDates: $state.selectedDates)
                    VStack {
                        RangeTimelineView(path: $path, selectedDates: $state.selectedDates, geometryProxy: geometryProxy, width: $width)
                            .background(ThemeState.shared.theme.dynamicCanvasColor)
                    }
                    .background(.white)
                    .opacity(1)
                }
    //            .background(ThemeState.shared.theme.canvasColor.opacity(ThemeState.shared.theme.canvasColor.components.opacity))
    //            .background(.blendMode(.difference))
                .ignoresSafeArea(edges: [.bottom])
                .onAppear(perform: {
                    width = geometryProxy.size.width
                })
                .onChange(of: geometryProxy.size, { oldValue, newValue in
                    width = geometryProxy.size.width
                    logger.debug("geometryProxy.width \(width)")
                    
//                    scrollViewHeight = geometryProxy.size.height
//                    logger.debug("geometryProxy.height \(scrollViewHeight)")
                })
            }
            .coordinateSpace(name: "scrollView")
            .navigationBarTitleDisplayMode(.inline)
    //        .onChange(of: calendarDate, { oldValue, newValue in
    //            state.selectedDates = [newValue]
    //            horizontalCalendarViewState.selectedDateRange = nil
    //        })
            .onChange(of: horizontalCalendarViewState.selectedDateRange?.id, { oldValue, newValue in
                if newValue != nil {
                    caldendarState = .none
                }
            })
            .onChange(of: caldendarState, { oldValue, newValue in
                switch newValue {
                case .day(let dayDate):
                    state.selectedDates = [dayDate.date]
                    horizontalCalendarViewState.selectedDateRange = nil
                case .week(let weekDate):
                    state.selectedDates = weekDate.days
                    horizontalCalendarViewState.selectedDateRange = nil
                case .month(let monthDate):
                    state.selectedDates = monthDate.start.getDaysOfMonth()
                    horizontalCalendarViewState.selectedDateRange = nil
                case .none:
                    break
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .popover(isPresented: $showCalendar, content: {
    //                    CalendarView(calendarDate: $calendarDate)
                        TimelineCalendarView(timelineCalendarState: $caldendarState)
                    })
                }
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

//struct TimelineDateRange: Identifiable {
//    let id = UUID()
//    let title: String
//    let type: TimelineDateRangeType
//    let date: Date
//}
//
//extension TimelineDateRange: Equatable {
//    
//}


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
