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
    
    @Environment(CalendarState.self) var calendarState
    
    var body: some View {
        @Bindable var calendarState = calendarState
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
                    DayCalendarView2(dayDate: $calendarState.dayDate)
                case .week:
                    WeekCalendarView(weekDate: $calendarState.weekDate)
                case .month:
                    MonthCalendarView(monthDate: $calendarState.monthDate)
                }
            }
            
            Spacer()
        }
//        .frame(width: 280)
        .pickerStyle(SegmentedPickerStyle())
    }
}
