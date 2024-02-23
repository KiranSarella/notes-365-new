//
//  HorizontalCalendarView.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import SwiftUI

enum TopFilterType {
    case dateRange
    case folder
    
    var icon: String {
        switch self {
        case .dateRange:
            "calendar"
        case .folder:
            "folder"
        }
    }
}

protocol TopFilterOption: Identifiable, Equatable {
    var id: UUID { get set }
    var title: String { get set }
    var filterType: TopFilterType { get set }
}

struct TimelineDateRange: TopFilterOption {
    var id = UUID()
    var title: String
    var filterType: TopFilterType
    
    let type: TimelineDateRangeType
    let date: Date
    var dateRange = [Date]()
}

struct TimelineFolderRange: TopFilterOption {
    var id = UUID()
    var title: String
    var filterType: TopFilterType
    
    let folderId: UUID
}

struct HorizontalCalendarView: View {
    @Binding var state: TimelineBaseViewState
    
    func makeAsSelected(_ item: any TopFilterOption) {
        if var newDateRangeFilter = item as? TimelineDateRange {
            newDateRangeFilter.dateRange = state.getDates(for: newDateRangeFilter)
            state.selectedFilterOption = newDateRangeFilter
        } else {
            state.selectedFilterOption = item
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    
                    ForEach(state.filterOptions, id: \.id) { item in
                        VStack {
                            if state.isSelected(input: item) {
                                Button {
                                    makeAsSelected(item)
                                } label: {
                                    Label(item.title, systemImage: item.filterType.icon)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    makeAsSelected(item)
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
                state.constructFilterItemsIfRequired()
            })
        }

    }
}
