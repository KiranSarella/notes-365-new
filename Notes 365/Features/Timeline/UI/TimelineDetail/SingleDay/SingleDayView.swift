//
//  SingleDayViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct SingleDayView: View {
    @Binding var dayTimelines: DayTimelineModel
    @Binding var discardTimelineInfo: DiscardTimelineInfo?
    @State var discardTimeline: Timeline?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            DayHeaderView(date: dayTimelines.date)
            SingleDayChangesListView(timelines: dayTimelines.timelines, discardTimeline: $discardTimeline, geometryProxy: geometryProxy, width: $width)
        }
        .onChange(of: discardTimeline) { oldValue, newValue in
            if let newValue = newValue {
                discardTimelineInfo =
                DiscardTimelineInfo(dayId: dayTimelines.id, date: dayTimelines.date, fileId: newValue.fileUUID, changeId: newValue.id)
            }
        }
//        .onAppear {
////            state.loadDay(date)
////            dayTimelines.timelines.removeFirst()
//        }
//        .onChange(of: state.isLoaded) { oldValue, newValue in
//            logger.info("isLoaded")
//            if newValue {
//                currentDateLoadingState = CurrentDateLoadingState(date: date, timmelinesCount: state.timelines.count)
//            }
//        }
    }
}

struct DayHeaderView: View {
    let date: Date
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(date.string(withFormat: "EEEE, d MMMM"))
                .listRowSeparator(.hidden)
                .padding(.horizontal)
                .font(.title)
                .fontDesign(.rounded)
                .fontWeight(.bold)
            }
            .padding(.vertical)
        }
        .listRowSeparator(.hidden)
    }
}

struct SingleDayChangesListView: View {
    var timelines: [Timeline]
    @Binding var discardTimeline: Timeline?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    
    var body: some View {
            // each note change content list
            ForEach(timelines) { noteChange in
                VStack {
                    NoteChangeHeadingView(noteChange: noteChange, discardTimeline: $discardTimeline)
                    .listRowSeparator(.hidden)
                    .padding()
                    HStack {
                        ReadOnlyMarkDownView(content: noteChange.content, width: $width)
                            .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
            }
    }
}

