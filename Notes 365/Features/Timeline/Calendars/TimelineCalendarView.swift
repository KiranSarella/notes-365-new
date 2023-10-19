//
//  SidebarView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

//struct TimelineCalendarView: View {
//    
//    @Binding var selectedDate:Date
//    
//    var body: some View {
//        VStack {
//            DatePicker(
//                    "Start Date",
//                    selection: $selectedDate,
//                    displayedComponents: [.date]
//                )
//                .datePickerStyle(.graphical)
//            
//            Spacer()
//        }
//    }
//}

///
/// events: calender type, selected day, selected week, selected month
struct TimelineCalendarView: View {
    
    @State private var calendarState = CalendarState()
    @Binding var timelineCalendarState: TimelineCalendarState
    
    var body: some View {
        VStack {
            // calendar type picker
            Picker("", selection: $calendarState.calenderType) {
                ForEach(CalendarType.allCases, id: \.self) { calendarType in
                    Text(calendarType.name).tag(calendarType)
                }
            }

            HStack(alignment: .bottom) {
                switch calendarState.calenderType {
                case .day:
                    DayCalendarView2(dayDate: $calendarState.dayDate, selectedDayDate: $calendarState.selectedDayDate)
                case .week:
                    WeekCalendarView(weekDate: $calendarState.weekDate, selectedWeekDate: $calendarState.selectedWeekDate)
                case .month:
                    MonthCalendarView(monthDate: $calendarState.monthDate, selectedMonthDate: $calendarState.selectedMonthDate)
                }
            }
            
            Spacer()
        }
//        .frame(width: 280)
        .pickerStyle(SegmentedPickerStyle())
        .onAppear {
            // update navigation according to user given inputs
            
            switch timelineCalendarState {
            case .day(let dayDate):
                calendarState.calenderType = .day
                calendarState.dayDate = dayDate
                calendarState.selectedDayDate = dayDate
            case .week(let weekDate):
                calendarState.calenderType = .week
                calendarState.weekDate = weekDate
                calendarState.selectedWeekDate = weekDate
            case .month(let monthDate):
                calendarState.calenderType = .month
                calendarState.monthDate = monthDate
                calendarState.selectedMonthDate = monthDate
            }
        }
        .onChange(of: calendarState.selectedDayDate) { oldValue, newValue in
            if let newValue = newValue {
                timelineCalendarState = .day(newValue)
                // remove old selections
                calendarState.selectedWeekDate = nil
                calendarState.selectedMonthDate = nil
            }
        }
        .onChange(of: calendarState.selectedWeekDate) { oldValue, newValue in
            if let newValue = newValue {
                timelineCalendarState = .week(newValue)
                // remove old selections
                calendarState.selectedDayDate = nil
                calendarState.selectedMonthDate = nil
            }
        }
        .onChange(of: calendarState.selectedMonthDate) { oldValue, newValue in
            if let newValue = newValue {
                timelineCalendarState = .month(newValue)
                // remove old selections
                calendarState.selectedDayDate = nil
                calendarState.selectedWeekDate = nil
            }
        }
        .onChange(of: calendarState.calenderType) { oldValue, newValue in
            
//            calendarState.oldCalenderType = oldValue
            calendarState.updateNavigation(oldValue, newValue)
        }
    }
}
