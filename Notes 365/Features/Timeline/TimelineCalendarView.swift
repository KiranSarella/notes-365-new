//
//  SidebarView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

struct TimelineCalendarView: View {
    
    @Binding var selectedDate:Date
    
    var body: some View {
        VStack {
            DatePicker(
                    "Start Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            
            Spacer()
        }
    }
}
