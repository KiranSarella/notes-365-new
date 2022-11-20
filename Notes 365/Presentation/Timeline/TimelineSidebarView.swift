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
                    DayCalendarView(selectedDate: $calendarState.selectedDate, dayDate: $calendarState.dayDate)
                case .week:
                    WeekCalendarView(weekDate: $calendarState.weekDate)
                case .month:
                    MonthCalendarView(monthDate: $calendarState.monthDate)
                }
            }
            
            
            //            // summary view
            //            HStack {
            //
            //                VStack {
            //                    Text("Summary ")
            //                        .font(.title2)
            //                }
            //
            //                Spacer()
            //            }.padding()
            
            
            Spacer()
            
        }
        .frame(width: 280)
        .pickerStyle(SegmentedPickerStyle())
    }
}




//struct DairySidebarView_Previews: PreviewProvider {
//
//    @State static var selectedDate = Date()
//    @State static var selectedCalendar = CalendarType.day
//
//    static var previews: some View {
//        TimelineSidebarView(selectedDate: $selectedDate, selectedCalendar: $selectedCalendar)
//    }
//}
