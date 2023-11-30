//
//  NotebookHeaderView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/06/22.
//

import SwiftUI

struct NoteChangeHeadingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isFocused = false
    var noteChange: Timeline
    @State var fullPath: String?
//    var showDiscard = false
    
//    @Binding var discardTimeline: Timeline?
    
//    func getAbsolutePath() -> String {
//        var components = noteChange.filePath.components(separatedBy: "/")
////        if components.count > 0 {
////            components.removeFirst()
////        }
//        // https://www.compart.com/en/unicode/U+203A
//        return components.joined(separator: "  \u{203A}   ")
//    }
    
    func getFullPath() {
        fullPath = NotebooksPathService.shared.fullPath(for: noteChange.fileUUID)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(noteChange.fileName.capitalized)
                    .lineLimit(1)
                    .listRowSeparator(.hidden)
//                    .strikethrough(noteChange.isNotebookExists ? false : true)
                    .font(.title)
                    .foregroundColor(.primary)
                Text(fullPath ?? "")
//                Text(getAbsolutePath())
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            Spacer()
            // discard button
            
//            Button {
//                print("one")
//            } label: {
//                Text("one")
//            }
//
//            Button {
//                print("two")
//            } label: {
//                Text("two")
//            }
            
//            if showDiscard && isFocused {
//                
//                Button {
//                    // inform delete action to parent
//                    print("## Discard")
//                    print(noteChange.fileName)
//                    print(noteChange.id, noteChange.content)
//                    
//                    discardTimeline = noteChange
//                } label: {
//                    Text("Discard")
//    //                Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
//                .help("Ignore changes in timeline")
//                .padding()
////                .opacity(showDiscard && isFocused ? 1 : 0)
//            }
            

        }
        .buttonStyle(.bordered)
        .background(colorScheme == .light ? Color.gray.opacity(0.2) : Color(UIColor.darkGray))
        .cornerRadius(4)
        .onHover { subscriptionStatus in
            isFocused = subscriptionStatus
        }
        .onAppear {
            if fullPath == nil {
                getFullPath()
            }
        }
    }
}
//
//struct NotebookHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotesTitleView(noteChange: TimelineThree(fileName: "Algorithms", filePath: "/algorithms", id: UUID()))
//    }
//}
