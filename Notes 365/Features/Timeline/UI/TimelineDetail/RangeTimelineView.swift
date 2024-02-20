//
//  RangeTimelineView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct RangeTimelineView: View {
    @Binding var path: NavigationPath
    @Binding var selectedDates: [Date]
    @State private var state = RangeTimelineState()
//    @State var discardTimelineInfo: DiscardTimelineInfo?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    @State var discardTimeline: Timeline?
    
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    var body: some View {
//        List {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
    //                ForEach($state.dayTimelineModels) { $dayTimelines in
    //                    SingleDayView(dayTimelines: $dayTimelines, discardTimelineInfo: $discardTimelineInfo, geometryProxy: geometryProxy, width: $width)
                    SingleDayChangesListView(timelines: $state.dayTimelineModels, discardTimeline: $discardTimeline, openTimeline: $state.openTimeline, geometryProxy: geometryProxy, width: $width)
    //                }
                    VStack {
                        if state.loadingState.displayMessage != nil {
                            HStack {
                                Spacer()
                                Text(state.loadingState.displayMessage ?? "")
                                    .listRowSeparator(.hidden)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(height: 100)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .scrollTargetLayout()
    //            .background(Color("editor_background", bundle: nil))
                .onAppear {
                    if state.dayTimelineModels.isEmpty {
                        Task {
                            state.startloading(days: selectedDates)
                        }
                    } else {
                        // if recently opended is today, refetch content, if not exists - remove it.
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            state.refreshOpenedTimelineContent()
                        }
                    }
                }
                .onChange(of: selectedDates, { oldValue, newValue in
                    state.startloading(days: newValue)
                })
                .onChange(of: discardTimeline) { oldValue, newValue in
                    if let newValue = newValue {
                        state.discardTimelineChanges(info: newValue)
                        discardTimeline = nil
                    }
                }
                .onChange(of: state.openTimeline) { oldValue, newValue in
                    if let newValue = newValue {
                        // open
//                        DispatchQueue.main.async {
//                            path.append(newValue)
//                        }
                        Task { @MainActor in
                            path.append(newValue)
                        }
                    }
                }
                .onChange(of: state.scrolledID) { oldValue, newValue in
                    logger.debug("scrolledID")
                    if state.loadingState != .done {
                        guard let lastUUID = state.dayTimelineModels.last?.id  else { return }
                        if newValue == lastUUID {
                            logger.debug("SCROLLED TO BOTTOM")
                            Task { @MainActor in
                                state.loadNext()
                            }
                        }
                    }
                }
            }
            .scrollPosition(id: $state.scrolledID, anchor: .bottom)
            .listStyle(PlainListStyle())
    //        .background(Color("editor_background", bundle: nil))
            .scrollContentBackground(.hidden)
        }
        .navigationDestination(for: Timeline.self) { t in
            NotebookContentView(isReadOnly: false, notebookId: t.fileUUID, fileName: t.fileName, notebookContentState: notebookContentState)
        }
    }
}

//#Preview {
//    RangeTimelineView()
//}

//struct LoadMoreViewNew: View {
//    @Binding var state: RangeTimelineState
//    var body: some View {
////        if state.canLoadMore {
//            VStack {
//                HStack {
//                    Spacer()
//                    Text("Loading.. range timeline")
//                    Spacer()
//                }
//                .progressViewStyle(CircularProgressViewStyle())
//                .foregroundStyle(.gray)
//                .frame(height: 80)
//                .onAppear {
//                    logger.debug("load more view appear")
////                    state.tryLoadMore()
//                }
//            }
//            .listRowSeparator(.hidden)
////        }
//    }
//}
