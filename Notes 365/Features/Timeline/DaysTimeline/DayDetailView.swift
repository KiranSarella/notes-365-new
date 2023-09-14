//
//  TimelineDetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 06/09/21.
//

import SwiftUI
import Foundation


struct DayDetailView2: View {
    
    var dayItem: DayDateItem
//    @EnvironmentObject var dayState: DayCalendarState
    
    var body: some View {
        
        Text("\(dayItem.date.string(withFormat: "mm-dd-yyyy"))")
            .onDisappear {
//                dayState.selectedDayItem = dayItem
                NotificationCenter.default.post(name: NSNotification.Name("daydetailview"), object: nil, userInfo: ["date": dayItem.date])
            }
            .onAppear {
                NotificationCenter.default.post(name: NSNotification.Name("daydetailview"), object: nil, userInfo: ["date": dayItem.date])
            }
    }
}

struct DayDetailView: View {
    
    var dayItem: DayDateItem?
    @Binding var navigationSplitViewVisibility: NavigationSplitViewVisibility
    
    @State private var dayState = DayDetailState()
    
    @State var deleteTimeline: Timeline?
    
    var body: some View {
        
        VStack(spacing: 0) {
            List {
                // date heading
                VStack {
                    HStack {
                        Spacer()
                        
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Text(dayState.dayDate.date.formatted(date: .abbreviated, time: .omitted))
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .font(.largeTitle)
                        } else {
                            Text(dayState.dayDate.date.formatted(date: .complete, time: .omitted))
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .font(.largeTitle)
                        }
                        
                        
                    }
                    .padding(.top, 30)
                }
                .listRowSeparator(.hidden)
                // day number
//                HStack(alignment: .center) {
//                    Spacer()
//                    VStack {
////                        Spacer()
//                        HStack {
//                            Text(dayState.dayNumberText)
//                                .listRowSeparator(.hidden)
//                                .font(.title3)
//                                .fontWeight(.bold)
//
////                            Toggle("", isOn: $dayState.showDayNumberFromDOB)
//                        }
////                        Spacer()
//                    }
//
//                    Spacer()
//                }
//                .listRowSeparator(.hidden)
                // list
                ForEach($dayState.timelineList) { $noteChange in
                    VStack {
                        // notebook heading view
                        NotesTitleView(noteChange: noteChange, showDelete: dayState.canDelete, deleteTimeline: $deleteTimeline)
                            .listRowSeparator(.hidden)
                        
                            HStack {
                                ReadOnlyMarkDownViewTwo(timeline: $noteChange)
//                                ReadOnlyMarkDownView(content: noteChange.content)
                                    .listRowSeparator(.hidden)
//                                    .padding()
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
                
            .listStyle(PlainListStyle())
//            .navigationTitle(dayState.dayDate.date.formattedDate())
        }
        .onChange(of: dayState.dayDate) { newValue in
            Task {
                dayState.generatorTask?.cancel()
                DispatchQueue.main.async {
                    dayState.currentState = .loading
                    dayState.timelineList.removeAll()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    dayState.readDayData(dayDate: newValue)
                }
//                try? await Task.sleep(nanoseconds: 3_000_000_000)
                
            }
        }
        .onChange(of: deleteTimeline, perform: { newValue in
            guard let newValue = newValue else { return }
            dayState.removeTimelineChanges(newValue)
            deleteTimeline = nil
        })
        .onAppear {
            
            if let date = dayItem?.date {
                CalendarState.shared.selectedDate = date
            }
            
//            dayState.updateDayNumberText()
            dayState.readDayData(dayDate: dayState.dayDate)
        }
        .onDisappear {
            dayState.generatorTask?.cancel()
        }
        .toolbar {
            // works for mac also, because of mac catalyst
            if UIDevice.current.userInterfaceIdiom == .pad {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if navigationSplitViewVisibility == .detailOnly {
                            navigationSplitViewVisibility = .doubleColumn
                        } else {
                            navigationSplitViewVisibility = .detailOnly
                        }
                    } label: {
                        if navigationSplitViewVisibility == .detailOnly {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                        } else {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                        }
                    }

                }
            }
        }
    }
}

class ContentCache {
    
    var contentsDB = [UUID: AttributedString]()
}

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    /*
     limitation: more then 2 empty lines are treated as same
     */
    func fixLineBreaks() -> String {
        let pattern = #"\n[^$(?=\S)]+"#
        //    print(content)
        let out1 = self.replacingOccurrences(of: pattern, with: "##-##", options: .regularExpression, range: nil)
        //print(out1)
        let out2 = out1.replacingOccurrences(of: "\n", with: "##*##")
        //print(out2)
        let out3 = out2.replacingOccurrences(of: "##-##", with: "\n\n\n")
        //print(out3)
        let out4 = out3.replacingOccurrences(of: "##*##", with: "\n\n")
        //    print(out4)
        
        return out4
    }
}

//
//struct TimelineDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineDetailView()
//    }
//}




