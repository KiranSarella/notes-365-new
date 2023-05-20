//
//  SidebarView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

struct TimelineSidebarView: View {
    
    @Binding var calendarID: CalendarType.ID?
    @EnvironmentObject var calendarState: CalendarState
    
    var body: some View {
        VStack {
            // calendar type picker
            Picker("", selection: $calendarState.calenderType) {
                ForEach(CalendarType.allCases, id: \.self) { calendarType in
                    Text(calendarType.name).tag(calendarType)
                }
            }
            .navigationTitle("Timeline")
            .onChange(of: calendarState.calenderType, perform: { newValue in
                calendarID = newValue.id
            })
            .padding()
            
            HStack(alignment: .bottom) {
                switch calendarState.calenderType {
                case .day:
//                    DayCalendarView(dayDate: $calendarState.dayDate)
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
