//
//  HorizontalCalendarView.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import SwiftUI


struct HorizontalCalendarView: View {
    
    @Binding var state: HorizontalCalendarViewState
    @Binding var selectedDates: [Date]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(state.dateRanges) { dateRange in
                        VStack {
                            if state.isSelected(input: dateRange) {
                                Button {
                                    state.selectedDateRange = dateRange
                                } label: {
                                    Text(dateRange.title)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    state.selectedDateRange = dateRange
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
            }
            .onAppear(perform: {
                if state.dateRanges.isEmpty || !state.loadedDate.isSameDayAs(DateTime.now()) {
                    state.dateRanges = state.constructDateRanges()
                    state.loadedDate = DateTime.now()
                    logger.debug("dateRanges.count - \(state.dateRanges.count)")
                    state.selectedDateRange = state.dateRanges.first
                }
            })
            .onChange(of: state.selectedDateRange, { oldValue, newValue in
                logger.debug("onChange - selectedDateRange: ")
                guard let newRangeObj = newValue else { return }
                selectedDates = state.getDates(for: newRangeObj)
            })
        }

    }
}
