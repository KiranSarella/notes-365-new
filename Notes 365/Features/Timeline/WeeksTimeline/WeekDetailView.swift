//
//  WeekDetailView.swift
//  MyNotes
//
//  Created by Kiran Sarella on 13/10/21.
//

import SwiftUI

struct WeekDetailView: View {
    
    @StateObject private var weekState = WeekDetailState()
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach($weekState.weekTimelineList) { $weekTimeline in
                    WeekSectionView(weekTimeline: $weekTimeline)
                        .listRowSeparator(.hidden)
                }
                HStack {
                    Spacer()
                    Text(weekState.currentState.message)
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
                //                    Text(MotivationQuestions.weekQuestions.randomElement() ?? "")
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
        }
        .onChange(of: weekState.weekDate, perform: { newValue in
            Task {
                weekState.generatorTask?.cancel()
                DispatchQueue.main.async {
                    weekState.currentState = .loading
                    weekState.weekTimelineList.removeAll()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    weekState.readWeekData(weekDate: newValue)
                }
            }
        })
//        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.modified"))) { output in
//            guard let newTheme = output.object as? MarkdownTheme else { return }
//            weekState.theme = newTheme
//        }
//        .onChange(of: weekState.theme) { newValue in
//            Task {
//                for weekIndex in 0..<weekState.weekTimelineList.count {
//                    for notesIndex in 0..<weekState.weekTimelineList[weekIndex].notes.count {
//                        await weekState.weekTimelineList[weekIndex].notes[notesIndex].updateWithTheme(theme: newValue)
//                    }
//                }
//            }
//        }
        .onAppear {
            weekState.readWeekData(weekDate: weekState.weekDate)
        }
        .onDisappear {
            weekState.generatorTask?.cancel()
        }
//        .navigationTitle(weekState.weekDate.start.formattedDate())
    }
    
    static func getWeekStartEndDates(date: Date) -> (Date, Date) {
        
        guard
            let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: date)
        else { fatalError() }
        
        let startDate = weekInterval.start
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        return (startDate, endDate)
    }
    
    static func getWeekDates(startDate: Date) -> [Date] {
        
        guard
            let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: startDate)
        else { fatalError() }
        
        // form first day date
        let firstDay = weekInterval.start
        
        var weekDates = [firstDay]
        
        // form 2nd to 7th day dates
        for i in 1...6 {
            let nextDayDate = Calendar.current.date(byAdding: .day, value: i, to: firstDay)!
            weekDates.append(nextDayDate)
        }
        
        return weekDates
    }
    
}


struct WeekSectionView: View {
    
    @Binding var weekTimeline: DayChanges
    
    var body: some View {
        // date heading
        VStack {
            HStack {
                Spacer()
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Text(weekTimeline.date.formatted(date: .abbreviated, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                } else {
                    Text(weekTimeline.date.formatted(date: .complete, time: .omitted))
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .font(.largeTitle)
                }
                
                
            }
            .padding(.top, 30)
        }
        DayTimelineTwoView(timelineList: $weekTimeline.notes)
    }
}


fileprivate struct DayTimelineTwoView: View {
    
    @Binding var timelineList: [Timeline]
    
    var body: some View {
        ForEach($timelineList) { $noteChange in
            VStack {
                NotesTitleView(noteChange: noteChange)
                    .listRowSeparator(.hidden)
                HStack {
                    ReadOnlyMarkDownViewTwo(timeline: $noteChange)
//                    ReadOnlyMarkDownView(content: noteChange.content)
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
