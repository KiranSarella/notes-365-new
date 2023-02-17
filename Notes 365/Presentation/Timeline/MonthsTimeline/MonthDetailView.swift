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
    
   @StateObject private var monthState = MonthDetailState()

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach($monthState.monthTimelineList, id: \.id) { $dayTimeline in
                    // for each day
                    MonthSectionView(date: monthState.monthDate.start, dayTimeline: $dayTimeline, theme: $monthState.theme)
                }
                HStack {
                    Spacer()
                    Text(monthState.currentState.message)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.gray)
                    Spacer()
                }
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
            .onAppear {
                monthState.readMonthData(monthDate: monthState.monthDate)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.modified"))) { output in
                guard let newTheme = output.object as? MarkdownTheme else { return }
                monthState.theme = newTheme
            }
            .onChange(of: monthState.theme) { newValue in
                Task {
                    for weekIndex in 0..<monthState.monthTimelineList.count {
                        for notesIndex in 0..<monthState.monthTimelineList[weekIndex].notes.count {
                            await monthState.monthTimelineList[weekIndex].notes[notesIndex].updateWithTheme(theme: newValue)
                        }
                    }
                }
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
    @Binding var theme: MarkdownTheme
    
    var body: some View {
        
        // day header
        VStack {
            HStack {
                Spacer()
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Text(dayTimeline.date.formatted(date: .abbreviated, time: .omitted))
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                } else {
                    Text(dayTimeline.date.formatted(date: .complete, time: .omitted))
                        .padding(.horizontal)
                        .font(.largeTitle)
                        .padding(.top, 30)
                }
                
                
            }
            
            DayTimelineTwoView(timelineList: $dayTimeline.notes, theme: $theme)
        }
    }
}

fileprivate struct DayTimelineTwoView: View {
    
    @Binding var timelineList: [Timeline]
    @Binding var theme: MarkdownTheme
    
    var body: some View {
        ForEach($timelineList) { $noteChange in
            VStack {
                NotesTitleView(noteChange: noteChange)
                HStack {
                    Text(noteChange.attriburedString!)
                        .padding()
                        .textSelection(.enabled)
                        .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                    Spacer()
                }
            }
        }
    }
}

