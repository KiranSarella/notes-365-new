//
//  SidebarView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

struct TimelineSidebarView: View {
    
    @EnvironmentObject var calendarState: CalendarState
    
    var body: some View {
        VStack {
            // calendar type picker
            Picker("", selection: $calendarState.calenderType) {
                ForEach(CalendarType.allCases, id: \.self) { calendarType in
                    Text(calendarType.name)
                }
            }
            .padding()
            
            HStack(alignment: .bottom) {
                switch calendarState.calenderType {
                case .day:
                    DayCalendarView(dayDate: $calendarState.dayDate)
                case .week:
                    WeekCalendarView(weekDate: $calendarState.weekDate)
                case .month:
                    MonthCalendarView(monthDate: $calendarState.monthDate)
                }
            }
            
            Spacer()
        }
        .frame(width: 280)
        .pickerStyle(SegmentedPickerStyle())
    }
}
