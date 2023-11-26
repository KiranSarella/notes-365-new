//
//  SingleDayViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI



struct SingleDayView: View {
    var date: Date
    @Binding var currentDateLoadingState: CurrentDateLoadingState
    @State private var state = SingleDayViewState()
    
    var body: some View {
        VStack(spacing: 0) {
            if state.isLoaded && state.timelines.count > 0 {
                DayHeaderView(date: date)
                SingleDayChangesListView(timelines: state.timelines)
            } else {
//                Text("Loading..")
            }
        }
        .onAppear {
            state.loadDay(date)
        }
        .onChange(of: state.isLoaded) { oldValue, newValue in
            logger.info("isLoaded")
            if newValue {
                currentDateLoadingState = CurrentDateLoadingState(date: date, timmelinesCount: state.timelines.count)
            }
        }
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
                .font(.largeTitle)
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
    var body: some View {
        // each note change content list
        ForEach(timelines) { noteChange in
            VStack {
                NoteChangeHeadingView(noteChange: noteChange)
                .listRowSeparator(.hidden)
                .padding()
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

