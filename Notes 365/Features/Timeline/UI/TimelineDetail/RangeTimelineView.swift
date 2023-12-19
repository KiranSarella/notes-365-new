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
    @State var discardTimelineInfo: DiscardTimelineInfo?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    var body: some View {
//        List {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach($state.dayTimelineModels) { $dayTimelines in
                    SingleDayView(dayTimelines: $dayTimelines, discardTimelineInfo: $discardTimelineInfo, geometryProxy: geometryProxy, width: $width)
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
//            .background(Color("editor_background", bundle: nil))
            .onAppear {
                state.startloading(days: selectedDates)
            }
            .onChange(of: selectedDates, { oldValue, newValue in
                state.startloading(days: newValue)
            })
            .onChange(of: discardTimelineInfo) { oldValue, newValue in
                if let newValue = newValue {
                    state.discardTimelineChanges(info: newValue)
                }
            }
        }
        .listStyle(PlainListStyle())
//        .background(Color("editor_background", bundle: nil))
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
                    logger.debug("load more view appear")
                    state.tryLoadMore()
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}
