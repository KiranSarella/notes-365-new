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
    @StateObject private var dayState = DayDetailState()

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach($dayState.timelineList) { $noteChange in
                    VStack {
                        // notebook heading view
                        NotesTitleView(noteChange: noteChange)
                            .listRowSeparator(.hidden)
                        HStack {
                            Text(noteChange.attriburedString!)
                                .listRowSeparator(.hidden)
                                .padding()
                                .textSelection(.enabled)
                                .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                }
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.modified"))) { output in
            guard let newTheme = output.object as? MarkdownTheme else { return }
            dayState.theme = newTheme
        }
        .onChange(of: dayState.theme) { newValue in
            Task {
                for i in 0..<dayState.timelineList.count {
                    await dayState.timelineList[i].updateWithTheme(theme: newValue)
                }
            }
        }
        .onAppear {
            
            if let date = dayItem?.date {
                CalendarState.shared.selectedDate = date
            }
            
            dayState.readDayData(dayDate: dayState.dayDate)
        }
        .onDisappear {
            dayState.generatorTask?.cancel()
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




