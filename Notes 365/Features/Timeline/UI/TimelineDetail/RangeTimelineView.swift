//
//  RangeTimelineView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct RangeTimelineView: View {
    @Binding var path: NavigationPath
    @Binding var timelineBaseState: TimelineBaseViewState
    @State private var state = RangeTimelineState()
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    @State var discardTimeline: Timeline?
    
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    var body: some View {
//        List {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    SingleDayChangesListView(timelines: $state.dayTimelineModels, discardTimeline: $discardTimeline, openTimeline: $timelineBaseState.openTimeline, geometryProxy: geometryProxy, width: $width)
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
                
            }
            .scrollPosition(id: $state.scrolledID, anchor: .bottom)
            .listStyle(PlainListStyle())
    //        .background(Color("editor_background", bundle: nil))
            .scrollContentBackground(.hidden)
        }
        .navigationDestination(for: Timeline.self) { t in
            NotebookContentView(isReadOnly: t.isDeleted, notebookId: t.fileUUID, fileName: t.fileName, state: notebookContentState)
        }
        .onAppear {
            if state.dayTimelineModels.isEmpty {
                Task {
                    if timelineBaseState.selectedFilterOption.filterType == .dateRange {
                        state.beginNewLoading(filter: timelineBaseState.selectedFilterOption)
                    }
                }
            } else {
                // if recently opended is today, refetch content, if not exists - remove it.
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    state.refreshOpenedTimelineContent(&timelineBaseState.openTimeline)
                }
            }
        }
        .onChange(of: timelineBaseState.selectedFilterOption.id, { oldValue, newValue in
            state.beginNewLoading(filter: timelineBaseState.selectedFilterOption)
        })
        .onChange(of: discardTimeline) { oldValue, newValue in
            if let newValue = newValue {
                state.discardTimelineChanges(info: newValue)
                discardTimeline = nil
            }
        }
        .onChange(of: timelineBaseState.openTimeline) { oldValue, newValue in
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
