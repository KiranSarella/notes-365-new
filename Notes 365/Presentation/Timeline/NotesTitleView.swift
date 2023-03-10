//
//  NotebookHeaderView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/06/22.
//

import SwiftUI

struct NotesTitleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var noteChange: Timeline
    
    func getAbsolutePath() -> String {
        var components = noteChange.filePath.components(separatedBy: "/")
//        if components.count > 0 {
//            components.removeFirst()
//        }
        // https://www.compart.com/en/unicode/U+203A
        return components.joined(separator: "  \u{203A}   ")
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
//                Text(noteChange.filePath)
                Text(getAbsolutePath())
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            Spacer()
        }
        .background(colorScheme == .light ? Color.gray.opacity(0.2) : Color(UIColor.darkGray))
        .cornerRadius(4)
    }
}
//
//struct NotebookHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotesTitleView(noteChange: TimelineThree(fileName: "Algorithms", filePath: "/algorithms", id: UUID()))
//    }
//}
