//
//  TimelineDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 21/09/23.
//

import SwiftUI

struct TimelineDetailView: View {
    
    @Binding var calendarID: CalendarType.ID?
    @Environment(CalendarState.self) var calendarState
    @State private var isShowingCalendar = false
    
    var body: some View {
        VStack {
            let calendarType = calendarState.calenderType
            switch calendarType {
            case .day:
                DayDetailView()
            case .week:
                WeekDetailView()
            case .month:
                MonthDetailView()
            }
        }
        .toolbar {
            // menu options
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingCalendar = true
                } label: {
                    Image(systemName: "calendar")
                }
                .foregroundColor(.primary)
                .popover(isPresented: $isShowingCalendar) {
                    TimelineSidebarView(calendarID: $calendarID)
                        .environment(calendarState)
                        .frame(width: 280)
                        .padding()
                }
            }
        }
        
    }
}

//#Preview {
//    TimelineDetailView()
//}
