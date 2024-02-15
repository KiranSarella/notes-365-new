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
    @Binding var discardTimeline: Timeline?
    @Binding var openTimeline: Timeline?
    
    func getFullPath() {
        fullPath = NotebooksPathService.shared.fullPath(for: noteChange.fileUUID)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(noteChange.fileName.capitalized)
                    .lineLimit(1)
                    .listRowSeparator(.hidden)
                    .font(.title)
                    .foregroundColor(.primary)
                Text(fullPath ?? "")
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
//            .listStyle(PlainListStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            Spacer()
            // discard button
            if isFocused {
                Button {
                    openTimeline = noteChange
                } label: {
                    Text("Open")
                }
                Button {
                    discardTimeline = noteChange
                } label: {
                    Text("Discard")
    //                Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .help("Ignore changes in timeline")
                .padding()
//                .opacity(showDiscard && isFocused ? 1 : 0)
            }
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


struct NoteChangeHeadingNewView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isFocused = false
    var fileUUID: UUID
    @State var fileName: String = "dummy"
    @State var fullPath: String?
//    @Binding var discardTimeline: Timeline?
//    @Binding var openTimeline: Timeline?
    
    func getFullPath() {
        fullPath = "file path > more path >"
//        fullPath = NotebooksPathService.shared.fullPath(for: fileUUID)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(fileName.capitalized)
                    .lineLimit(1)
                    .listRowSeparator(.hidden)
                    .font(.title)
                    .foregroundColor(.primary)
                Text(fullPath ?? "")
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
//            .listStyle(PlainListStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            Spacer()
            // discard button
            if isFocused {
                Button {
//                    openTimeline = noteChange
                } label: {
                    Text("Open")
                }
                Button {
//                    discardTimeline = noteChange
                } label: {
                    Text("Discard")
    //                Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .help("Ignore changes in timeline")
                .padding()
//                .opacity(showDiscard && isFocused ? 1 : 0)
            }
        }
        .listRowSeparator(.hidden)
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
