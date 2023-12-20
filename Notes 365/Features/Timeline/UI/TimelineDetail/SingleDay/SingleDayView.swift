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
//                .background(Color("editor_background", bundle: nil))
        }
//        .background(Color("editor_background", bundle: nil))
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
    
    var dateString: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            date.string(withFormat: "EEE, d MMM")
        } else {
            date.string(withFormat: "EEEE, d MMMM")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(dateString)
                .listRowSeparator(.hidden)
                .padding(.horizontal)
                .font(.largeTitle)
                .fontDesign(.rounded)
                .fontWeight(.bold)
//                .background(Color("editor_background", bundle: nil))
            }
            .padding(.vertical)
        }
//        .background(Color("editor_background", bundle: nil))
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
                    List {
                        NoteChangeHeadingView(noteChange: noteChange, discardTimeline: $discardTimeline)
#if !targetEnvironment(macCatalyst)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    discardTimeline = noteChange
                                } label: {
                                    Text("Discard")
                                }
                            }
#endif
                        .listStyle(PlainListStyle())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowSpacing(0)
                        .listSectionSpacing(0)
                        .background(Color.clear)
                    }
                    .frame(height: 110)
                    .scrollDisabled(true)
//                    .background(Color("editor_background", bundle: nil))
//                    HStack {
//                        Text(noteChange.content ?? "--")
//                            .background(Color(UIColor(named: "editor_background")!))
                        ReadOnlyMarkDownView(content: noteChange.content, width: $width)
                            .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
//                        Spacer()
//                        .background(Color("editor_background", bundle: nil))
//                    }
                    .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
//                .background(Color("editor_background", bundle: nil))
            }
    }
}

