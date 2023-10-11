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
    @State var deleteTimeline: Timeline?
    
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
                        NoteChangeHeadingView(noteChange: noteChange, showDelete: dayState.canDelete, deleteTimeline: $deleteTimeline)
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
                
//                if dayState.canLoadMore {
//                    // load more view
//                    
//                }
//            
//            VStack {
//                VStack {
//                    Text("Load more")
//                }
//                .background(Color.green)
//                .frame(height: 50)
//                .onAppear {
//                    print("load more appear")
//                    if isFirstTimeAppear == false {
//                        print("reached end")
//                        dayState.tryLoadMore()
//                    }
//                    if isFirstTimeAppear {
//                        self.isFirstTimeAppear = false
//                    }
//                }
//            }
                
//            }
                
            
//            .navigationTitle(dayState.dayDate.date.formattedDate())
        }
//        .onChange(of: dayState.dayDate) { newValue in
//            Task {
//                dayState.generatorTask?.cancel()
//                DispatchQueue.main.async {
//                    dayState.currentState = .loading
//                    dayState.timelineList.removeAll()
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    // your code here
//                    dayState.readDayData(dayDate: newValue)
//                }
////                try? await Task.sleep(nanoseconds: 3_000_000_000)
//                
//            }
//        }
        .onChange(of: deleteTimeline, perform: { newValue in
            guard let newValue = newValue else { return }
            dayState.removeTimelineChanges(newValue)
            deleteTimeline = nil
        })
        .onAppear {
//            dayState.readDayData(dayDate: dayState.dayDate)
        }
        .onDisappear {
            dayState.generatorTask?.cancel()
        }
    }
}



