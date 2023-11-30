//
//  RangeTimelineView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct RangeTimelineView: View {
    @Binding var selectedDates: [Date]
    @State private var state = RangeTimelineState()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(state.dayTimelineModels) { dayTimelines in
                    SingleDayView(dayTimelines: dayTimelines)
                }
                VStack {
                    if state.statusMessage != nil {
                        HStack {
                            Spacer()
                            Text(state.statusMessage ?? "")
                                .listRowSeparator(.hidden)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: 100)
                        .listRowSeparator(.hidden)
                    }
                }
//                LoadMoreViewNew(state: $state)
            }
            .onAppear {
                state.startloading(days: selectedDates)
            }
            .onChange(of: selectedDates, { oldValue, newValue in
                state.startloading(days: newValue)
            })
//            .onChange(of: state.currentDateLoadingState) { oldValue, newValue in
//                logger.info("currentDayContentsCount: \(newValue.timmelinesCount)")
//                state.currentDayLoaded = true
//                if newValue.timmelinesCount > 0 {
//                    state.daysContentExists.insert(true)
//                    state.statusMessage = nil
//                    state.atleastOneDayExists = true
//                    state.canLoadMore = true
//                } else {
//                    state.daysContentExists.insert(false)
//                }
////                if state.atleastOneDayExists == false {
//                state.loadNextDay()
////                }
//            }
//            .onChange(of: state.currentDayLoaded) { oldValue, newValue in
//                if newValue {
//                    state.loadNextDay()
//                }
//            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
}

//#Preview {
//    RangeTimelineView()
//}

struct LoadMoreViewNew: View {
    @Binding var state: RangeTimelineState
    var body: some View {
        if state.canLoadMore {
            VStack {
                HStack {
                    Spacer()
                    Text("Loading.. range timeline")
                    Spacer()
                }
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundStyle(.gray)
                .frame(height: 80)
                .onAppear {
                    logger.info("load more view appear")
                    state.tryLoadMore()
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}
