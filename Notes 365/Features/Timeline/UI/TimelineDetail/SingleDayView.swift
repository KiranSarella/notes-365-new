//
//  SingleDayViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct DayTimelineModel: Identifiable {
    let id = UUID()
    let date: Date
    var timelines = [Timeline]()
    
    mutating func showTimelines(newValues: [Timeline]) {
        timelines = newValues
    }
}

struct DiscardTimelineInfo: Equatable {
//    let dayId: UUID
    let date: Date
    let fileId: UUID
    let changeId: String
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
    @Binding var timelines: [Timeline]
    @Binding var discardTimeline: Timeline?
    @Binding var openTimeline: Timeline?
    @Binding var editTimeline: Timeline?
    
    var geometryProxy: GeometryProxy
    @Binding var width: CGFloat
//    @State var state = SingleDayTimelinesListState()
    
    
    
    var body: some View {
            // each note change content list
        VStack {
            ForEach($timelines) { $noteChange in
                VStack {
                    if noteChange.isFirst {
                        DayHeaderView(date: noteChange.date)
                    }
                    List {
                        NoteChangeHeadingView(noteChange: noteChange, discardTimeline: $discardTimeline, openTimeline: $openTimeline, editTimeline: $editTimeline)
#if !targetEnvironment(macCatalyst)
                            .swipeActions(edge: .trailing) {
                                Menu {
                                    Button(role: .destructive) {
                                        discardTimeline = noteChange
                                    } label: {
                                        Text("Discard Timeline")
                                    }
//                                    .foregroundColor(.primary)
                                    
                                    if noteChange.date.isToday == false {
                                        Button {
                                            editTimeline = noteChange
                                        } label: {
                                            Text("Edit Timeline")
                                        }
                                        .foregroundColor(.primary)
                                    }
                                    
                                    if !noteChange.fileName.isEmpty {
                                        Button {
                                            Task { @MainActor in
                                                openTimeline = noteChange
                                            }
                                        } label: {
                                            Text("Open Notebook")
                                        }
                                        .foregroundColor(.primary)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
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
                    
                    
//                    SmartViewerRepresentable(content: $noteChange.content, width: $width)
//                        .frame(width: 500, height: 500)
                 
                        ReadOnlyMarkDownView(content: $noteChange.content, width: $width)
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
