//
//  SidebarView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

struct TimelineSidebarView: View {
    
    @Binding var calendarID: CalendarType.ID?
    @Environment(CalendarState.self) var calendarState
    
    @State private var date = Date()
    
    var body: some View {
        @Bindable var calendarState = calendarState
        
        
        VStack {
            
            DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            
            Spacer()
        }
        .onChange(of: date) { oldValue, newValue in
            print(oldValue, newValue)
        }
        
//        VStack {
//            // calendar type picker
//            Picker("", selection: $calendarState.calenderType) {
//                ForEach(CalendarType.allCases, id: \.self) { calendarType in
//                    Text(calendarType.name).tag(calendarType)
//                }
//            }
////            .navigationTitle("Timeline")
//            .onChange(of: calendarState.calenderType, perform: { newValue in
//                calendarID = newValue.id
//            })
////            .padding()
//            
//            HStack(alignment: .bottom) {
//                switch calendarState.calenderType {
//                case .day:
//                    DayCalendarView2(dayDate: $calendarState.dayDate)
//                case .week:
//                    WeekCalendarView(weekDate: $calendarState.weekDate)
//                case .month:
//                    MonthCalendarView(monthDate: $calendarState.monthDate)
//                }
//            }
//            
//            Spacer()
//        }
////        .frame(width: 280)
//        .pickerStyle(SegmentedPickerStyle())
    }
}
