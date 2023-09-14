//
//  MonthDetailView.swift
//  MyNotes
//
//  Created by Kiran Sarella on 13/10/21.
//

import SwiftUI


struct MonthDetailWrapperView: View {
    
    var body: some View {
    
        // if url exists, load actual view
        // else block with alert
        
        if EnvironmentState.shared.basePathURL != nil {
            Text("Please enable iCloud.")
        } else {
            MonthDetailView()
        }
    }
}

struct MonthDetailView: View {
    
   @State private var monthState = MonthDetailState()

    var body: some View {
        VStack(spacing: 0) {
//            GeometryReader { g in
                List {
                    ForEach($monthState.monthTimelineList, id: \.id) { $dayTimeline in
                        // for each day
                        MonthSectionView(date: monthState.monthDate.start, dayTimeline: $dayTimeline, width: 0)
                            .listRowSeparator(.hidden)
                    }
                    HStack {
                        Spacer()
                        Text(monthState.currentState.message)
                            .listRowSeparator(.hidden)
                            .fontWeight(.ultraLight)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    //                // motivation question
                    //                HStack {
                    //                    Spacer()
                    //
                    //                    Text(MotivationQuestions.monthQuestions.randomElement() ?? "")
                    //                        .fontWeight(.thin)
                    //                        .foregroundColor(.gray)
                    //                        .padding()
                    //                        .opacity(currentState == .empty ? 1 : 0)
                    //
                    //                    Spacer()
                    //                }
                    //                .padding()
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    monthState.readMonthData(monthDate: monthState.monthDate)
                }
                .onChange(of: monthState.monthDate, perform: { newValue in
                    Task {
                        monthState.generatorTask?.cancel()
                        DispatchQueue.main.async {
                            monthState.currentState = .loading
                            monthState.monthTimelineList.removeAll()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // your code here
                            monthState.readMonthData(monthDate: newValue)
                        }
                    }
                })
                .onDisappear {
                    monthState.generatorTask?.cancel()
                }
//            }
        }
        .toolbar {
//            ScaleFontView(theme: $theme)
        }
    }
    
    
    static func getMonthStartEndDates(date: Date) -> (Date, Date) {
        
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: date)
        else { fatalError() }
        
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        
        return (startDate, endDate)
    }
    
}

// each day
struct MonthSectionView: View {
    
    var date: Date
    @Binding var dayTimeline: DayChanges
    var width: CGFloat
    
    var body: some View {
        
        // day header
        VStack {
            HStack {
                Spacer()
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Text(dayTimeline.date.formatted(date: .abbreviated, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                } else {
                    Text(dayTimeline.date.formatted(date: .complete, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                }
            }
            
            DayTimelineTwoView(timelineList: $dayTimeline.notes)
        }
    }
}

fileprivate struct DayTimelineTwoView: View {
    
    @Binding var timelineList: [Timeline]
    
    var body: some View {
        ForEach($timelineList) { $noteChange in
            VStack {
                NotesTitleView(noteChange: noteChange, deleteTimeline: Binding.constant(nil))
                HStack {
                    
                    ReadOnlyMarkDownViewTwo(timeline: $noteChange)
                    
//                    ReadOnlyMarkDownView(content: noteChange.content)
                    
//                    EditorViewUI2(theme: theme,
//                                 text: noteChange.content ?? "no content",
//                                 isEditable: false,
//                                  isEditor: false, width: width)
//                        .frame(height: calculateHeight(noteChange.attriburedString, width: width))
//                    .setDisplay(width: width)
//                    Text(noteChange.attriburedString!)
                        .listRowSeparator(.hidden)
//                        .padding()
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                    Spacer()
                }
            }
        }
    }
}

