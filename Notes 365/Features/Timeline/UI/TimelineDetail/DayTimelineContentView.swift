//
//  DayTimelineContentView.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI

struct DayTimelineModel {
    let date: Date
    var timelines = [Timeline]()
}

//@Observable
//class TimelistListViewState {
//    
//}

@Observable
class DayTimelineContentState {
    let timelineBusiness: TimelineInteractor = BusinessFactory.timelineInteractor()
    var dayTimelines = [DayTimelineModel]()
    var currentDate: Date = Date()
    var canLoadMore = false
    var loadingDayChanges = true
    
    init() { }
    
    func loadDay(_ date: Date) {
        logger.info("load day: \(date)")
        Task {
            currentDate = date
            loadingDayChanges = true
            canLoadMore = false
            do {
                await NotebooksPathService.shared.refreshNotebooksInfo()
                let results = try timelineBusiness.fetchDayTimelineNoteChanges(date: date)
                let timelines = results.map { $0.timeline }
                if timelines.count > 0 {
                    let dayTimeline = DayTimelineModel(date: date, timelines: timelines)
                    dayTimelines.append(dayTimeline)
                    
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    loadingDayChanges = false
                    canLoadMore = true
                }
            } catch let error {
                print(error)
                loadingDayChanges = false
            }
        }
    }
    
    func tryLoadMore() {
        logger.info("tryLoadMore - loadingDayChanges: \(self.loadingDayChanges)")
        // have to maintain queue? - what if day content is single line?
        if loadingDayChanges {
            return
        }
        processNextDay()
    }
    
    func processNextDay() {
        logger.info("processNextDay")
        loadDay(currentDate.dayBefore)
    }
}

struct DayTimelineContentView: View {
    
    var initialDate: Date
    @State private var state = DayTimelineContentState()
    
    var body: some View {
        VStack {
            ForEach(state.dayTimelines, id: \.date) { dayTimeline in
                SingleDayView(dayTimeline: dayTimeline)
            }
            LoadMoreViewNew(state: $state)
        }
        .onAppear {
            state.loadDay(initialDate)
        }
    }
}

struct SingleDayView: View {
    var dayTimeline: DayTimelineModel
    var body: some View {
        VStack(spacing: 0) {
            // day heading
            VStack {
                HStack {
                    Spacer()
                    Text(dayTimeline.date.string(withFormat: "EEEE, d MMMM"))
                    .listRowSeparator(.hidden)
                    .padding(.horizontal)
                    .font(.largeTitle)
                }
                .padding(.vertical)
            }
            .listRowSeparator(.hidden)
            // each note change content list
            ForEach(dayTimeline.timelines) { noteChange in
                VStack {
                    NoteChangeHeadingView(noteChange: noteChange)
                    .listRowSeparator(.hidden)
                    .padding()
//                    .padding(.bottom, 10)
                    // content
                    HStack {
                        ReadOnlyMarkDownView(content: noteChange.content, width: 600)
//                            ReadOnlyMarkDownViewTwo(timeline: noteChange)
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
}

struct LoadMoreViewNew: View {
    @Binding var state: DayTimelineContentState
    var body: some View {
        if state.canLoadMore {
            VStack {
                HStack {
                    Spacer()
                    Text("Loading..")
                    Spacer()
                }
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundStyle(.gray)
                .frame(height: 80)
                .onAppear {
                    print("load more appear")
                    state.tryLoadMore()
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}
