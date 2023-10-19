//
//  TimelineDetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 06/09/21.
//

import SwiftUI
import Foundation

struct DayChangesView: View {
    
    var date: Date
    @Binding var timelines: [Timeline]
    @Binding var dayState: TimelineDetailState
    @State var discardTimeline: Timeline?
    
    @State var isFirstTimeAppear = true
    
    var body: some View {
        
        VStack(spacing: 0) {
            // day heading
            VStack {
                HStack {
                    Spacer()
                    Text(date.string(withFormat: "EEEE, d MMMM"))
                    .listRowSeparator(.hidden)
                    .padding(.horizontal)
                    .font(.largeTitle)
                }
                .padding(.vertical)
            }
            .listRowSeparator(.hidden)
            
            // each note change content list
            ForEach($timelines) { $noteChange in
                VStack {
                    // notebook heading view
                    NoteChangeHeadingView(noteChange: noteChange, showDiscard: dayState.canDiscard, discardTimeline: $discardTimeline)
                    .listRowSeparator(.hidden)
                    .padding(.bottom, 10)
                    // content
                    HStack {
                        ReadOnlyMarkDownViewTwo(timeline: $noteChange)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
            }
            // status message
            HStack {
                Spacer()
                Text(dayState.currentState.message)
                .listRowSeparator(.hidden)
                .fontWeight(.ultraLight)
                .foregroundColor(.gray)
                
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
        .onChange(of: discardTimeline, { oldValue, newValue in
            guard let newValue = newValue else { return }
            dayState.removeTimelineChanges(newValue)
            discardTimeline = nil
        })
    }
}



