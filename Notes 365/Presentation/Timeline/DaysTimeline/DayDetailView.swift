//
//  TimelineDetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 06/09/21.
//

import SwiftUI
import Foundation

struct DayDetailView: View {
    
    @StateObject private var dayState = DayDetailState()
    
    init(date: Date) {
//        self.dayState.dayDate = DayDate(date: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach($dayState.timelineList) { $noteChange in
                    VStack {
                        
                        // notebook heading view
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
                HStack {
                    Spacer()
                    Text(dayState.currentState.message)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.gray)
                   
                    Spacer()
                }
//                // motivation question
//                HStack {
//                    Spacer()
//                    
//                    Text(MotivationQuestions.dayQuestions.randomElement() ?? "")
//                        .fontWeight(.thin)
//                        .foregroundColor(.gray)
//                        .padding()
//                        .opacity(currentState == .empty ? 1 : 0)
//                    
//                    Spacer()
//                }
//                .padding()
            }
        }
        .onChange(of: dayState.dayDate) { newValue in
//
//            if dayState.speechState != .stopped {
//                dayState.speechHelper.stopSpeech()
//                dayState.speechState = .stopped
//            }
            
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
            dayState.readDayData(dayDate: dayState.dayDate)
        }
        .onDisappear {
            dayState.generatorTask?.cancel()
//            if dayState.speechState != .stopped {
//                dayState.speechHelper.stopSpeech()
//                dayState.speechState = .stopped
//            }
        }
        .toolbar {
            
//            Button {
//
//                switch dayState.speechState {
//
//                case .stopped:
//                    var input = ""
//                    for timeline in dayState.timelineList {
//                        input += timeline.fileName
//                        input += "\n"
//                        input += timeline.content ?? ""
//                        input += "\n"
//                    }
//
////                    var attrInput = NSMutableAttributedString()
////                    for timeline in timelineList {
////
////                        if let attrStr = timeline.attriburedString {
////                            attrInput.append(NSAttributedString(attrStr))
////                        }
////                    }
//
//
//                    dayState.speechHelper.startSpeech(string: input)
//
////                    speechHelper.startSpeech(attributedStting: attrInput)
//
//                    dayState.speechState = .playing
//
//                    dayState.speechHelper.finished = {
//                        dayState.speechState = .stopped
//                    }
//
//                case .playing:
//
//                    dayState.speechHelper.pauseSpeech()
//                    dayState.speechState = .paused
//                case .paused:
//                    dayState.speechHelper.continueSpeech()
//                    dayState.speechState = .playing
//                }
//
//
//            } label: {
//                Text(dayState.speechState.buttonTitle)
//            }

            
        }
    }
}



//struct MarkdownViewer: View {
//
//    var noteChange: TimelineTwo
//
//    @State private var attributedString: AttributedString?
//
//    @Binding var contentCache: ContentCache
//
//    var body: some View {
//
//        if attributedString != nil {
//            Text(attributedString!)
//        } else {
//            Text("loading")
//                .foregroundColor(.gray)
//                .task {
//                    attributedString = AttributedString(attributedText(from: noteChange.content))
//                    if let attributedString = attributedString {
//                        contentCache.contentsDB[noteChange.id] = attributedString
//                    }
//                }
//        }
//    }
//
//
//
//}

///// Transforms markdown text to NSAttributedString
//func attributedText(from markdown: String, theme newTheme: MarkdownTheme) -> NSAttributedString {
//    print(#function)
//    return Markdownosaur.attributedText(from: markdown, theme: newTheme)
//}

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




