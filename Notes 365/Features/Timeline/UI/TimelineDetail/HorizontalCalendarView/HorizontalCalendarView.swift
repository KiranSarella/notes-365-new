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
                    
//                    ForEach(state.list, id: \.id) { item in
//                        Label(item.title, systemImage: item.filterType.icon)
//                    }
                    
                    ForEach(state.dateRanges, id: \.id) { item in
                        VStack {
                            if state.isSelected(input: item) {
                                Button {
                                    if let item = item as? TimelineDateRange {
                                        state.selectedDateRange = item
                                    }
                                } label: {
                                    Label(item.title, systemImage: item.filterType.icon)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    if let item = item as? TimelineDateRange {
                                        state.selectedDateRange = item
                                    }
                                } label: {
                                    Label(item.title, systemImage: item.filterType.icon)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(5)
                        .id(item.id)
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
            .onChange(of: state.selectedDateRange?.id, { oldValue, newValue in
                logger.debug("onChange - selectedDateRange: ")
                guard let newValue = newValue else { return }
                guard let newRangeObj = state.selectedDateRange as? TimelineDateRange else { return }
                selectedDates = state.getDates(for: newRangeObj)
            })
        }

    }
}
