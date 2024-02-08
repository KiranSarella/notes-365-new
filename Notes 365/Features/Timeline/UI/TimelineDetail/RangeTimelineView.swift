//
//  RangeTimelineView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI


struct RangeTimelineNewView: View {
    @Binding var selectedDates: [Date]
    @State private var state = RangeTimelineNewState()
    @Binding var width: CGFloat
    
    var body: some View {
        ScrollView(.vertical) {
//        List {
            ForEach(state.items) { item in
                switch item.type {
                case .date:
                    DayHeaderView(date: item.date)
                case .path:
                    //                Text(item.filePath)
                    NoteChangeHeadingNewView(fileUUID: item.fileUUID)
                case .content:
                
                    ReadOnlyMarkDownView(content: item.content, width: $width)
                        .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)
                }
            }
        }
        .onAppear(perform: {
            state.loadItems()
        })
        .listStyle(PlainListStyle())
    }
}

struct RangeTimelineView: View {
    @Binding var selectedDates: [Date]
    @State private var state = RangeTimelineState()
    @State var discardTimelineInfo: DiscardTimelineInfo?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    var body: some View {
//        List {
        ScrollView(.vertical, showsIndicators: true) {
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
//                    .id("loadmore")
            }
            .scrollTargetLayout()
//            .background(Color("editor_background", bundle: nil))
            .onAppear {
                Task {
                    await NotebooksPathService.shared.refreshNotebooksInfo()
                    state.startloading(days: selectedDates)
                    // reset
                    state.scrolledID = nil
                }
            }
            .onChange(of: selectedDates, { oldValue, newValue in
                state.startloading(days: newValue)
            })
            .onChange(of: discardTimelineInfo) { oldValue, newValue in
                if let newValue = newValue {
                    state.discardTimelineChanges(info: newValue)
                }
            }
            .onChange(of: state.scrolledID) { oldValue, newValue in
                logger.debug("scrolledID")
                print(state.scrolledID ?? "nil")
                guard let lastUUID = state.dayTimelineModels.last?.id  else { return }
                if newValue == lastUUID {
                    logger.debug("SCROLLED TO BOTTOM")
                    state.tryLoadNextDay()
                }
            }
        }
        .scrollPosition(id: $state.scrolledID, anchor: .bottom)
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
//        if state.canLoadMore {
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
//                    state.tryLoadMore()
                }
            }
            .listRowSeparator(.hidden)
//        }
    }
}
