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
    @State var openTimeline: Timeline?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
    @State private var notebookContentState = NotebookContentState(business: BusinessFactory.createNotebookContentBusinessFactory())
    
    
    var body: some View {
        VStack(spacing: 0) {
            DayHeaderView(date: dayTimelines.date)
            SingleDayChangesListView(timelines: dayTimelines.timelines, discardTimeline: $discardTimeline, openTimeline: $openTimeline, geometryProxy: geometryProxy, width: $width)
//                .background(Color("editor_background", bundle: nil))
        }
//        .onAppear(perform: {
//            displayOneByOne()
//        })
//        .background(Color("editor_background", bundle: nil))
        .onChange(of: discardTimeline) { oldValue, newValue in
            if let newValue = newValue {
                discardTimelineInfo =
                DiscardTimelineInfo(dayId: dayTimelines.id, date: dayTimelines.date, fileId: newValue.fileUUID, changeId: newValue.id)
            }
        }
        .onChange(of: openTimeline) { oldValue, newValue in
            if let newValue = newValue {
//                newValue.fileUUID
                
                // if notebook id valid
                // present it
                
//                NotebookContentView(isReadOnly: false, notebookId: newValue.fileUUID, fileName: newValue.fileName, notebookContentState: notebookContentState)
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
            date.string(withFormat: "EEEE, d MMM")
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

@Observable
class SingleDayTimelinesListState {
    var timelines = [Timeline]()
    var timelinesToDisplay = [Timeline]()
    
    func displayOneByOne() {
        logger.debug("\(#function)")
        if timelines.isEmpty { return }
        
        let tm = timelines.removeFirst()
        timelinesToDisplay.append(tm)
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            displayOneByOne()
        }
    }
}

struct SingleDayChangesListView: View {
    var timelines: [Timeline]
    @Binding var discardTimeline: Timeline?
    @Binding var openTimeline: Timeline?
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
//    @State var state = SingleDayTimelinesListState()
    
    var body: some View {
            // each note change content list
        VStack {
            ForEach(timelines) { noteChange in
                VStack {
                    if noteChange.isFirst {
                        DayHeaderView(date: noteChange.date)
                    }
                    List {
                        NoteChangeHeadingView(noteChange: noteChange, discardTimeline: $discardTimeline)
#if !targetEnvironment(macCatalyst)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    openTimeline = noteChange
                                } label: {
                                    Text("Open")
                                }
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
                    
//                    LazyVStack {
//                        ReadOnlyMarkDownView(content: noteChange.content, width: $width)
//                            .padding(.bottom)
//                        .listRowSeparator(.hidden)
//                        .textSelection(.enabled)
//                        .lineSpacing(EditorSettings.lineSpacing)
//                    }
                    
                 
                        ReadOnlyMarkDownView(content: noteChange.content, width: $width)
                            .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                        .listRowSeparator(.hidden)
                    
                    
                        
                    
//                        Spacer()
//                        .background(Color("editor_background", bundle: nil))
//                    }
                    
                }
//                .id(noteChange.id)
                .listRowSeparator(.hidden)
//                .background(Color("editor_background", bundle: nil))
            }
        }
//        .onAppear(perform: {
//            state.timelines = timelines
//            state.displayOneByOne()
//        })
    }
}

