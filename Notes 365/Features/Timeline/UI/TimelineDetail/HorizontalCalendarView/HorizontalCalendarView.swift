//
//  HorizontalCalendarView.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import SwiftUI


struct HorizontalCalendarView: View {
    
    @State private var state = HorizontalCalendarViewState()
    @Binding var selectedDates: [Date]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(state.dateRanges) { dateRange in
                        VStack {
                            if state.isSelected(input: dateRange) {
                                Button {
                                    
                                } label: {
                                    Text(dateRange.title)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    state.selectedDateRange = dateRange
                                    selectedDates = state.getDates(for: dateRange)
                                } label: {
                                    Text(dateRange.title)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(5)
                        .id(dateRange.id)
                    }
                }
                .padding(.horizontal)
            }.onAppear {
                state.selectedDateRange = state.dateRanges.first
                if let selectedDateRange = state.selectedDateRange {
                    selectedDates = state.getDates(for: selectedDateRange)
                }
            }
        }

    }
}
