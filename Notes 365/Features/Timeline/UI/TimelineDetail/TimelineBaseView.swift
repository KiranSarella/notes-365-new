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
                    HorizontalCalendarView(state: $state)
                    VStack {
                        RangeTimelineView(path: $path, timelineBaseState: $state, geometryProxy: geometryProxy, width: $width)
                            .background(ThemeState.shared.theme.canvasColor)
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
            .onChange(of: state.selectedFilterOption.id, { oldValue, newValue in
                if let filterOption = state.selectedFilterOption as? TimelineDateRange {
                    if filterOption.type != .calendar {
                        caldendarState = .none
                    }
                } else {
                    caldendarState = .none
                }
            })
            .onChange(of: caldendarState, { oldValue, newValue in
                if newValue == .none {
                    return
                }
                var filter =  TimelineDateRange(title: "", filterType: .dateRange, type: TimelineDateRangeType.calendar, date: DateTime.now())
                
                switch newValue {
                case .day(let dayDate):
                    filter.dateRange = [dayDate.date]
                case .week(let weekDate):
                    filter.dateRange = weekDate.days
                case .month(let monthDate):
                    filter.dateRange = monthDate.start.getDaysOfMonth()
                case .none:
                    break
                }
                
                state.selectedFilterOption = filter
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
        .onAppear(perform: {
            if state.openTimeline == nil {
                state.constructFilterItemsIfRequired()
            }
        })
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
