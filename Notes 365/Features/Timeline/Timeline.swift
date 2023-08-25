//
//  TimelineThree.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation
import Combine


public struct Timeline: Identifiable {
    public let id: UUID = UUID()
    var fileUUID: UUID
    var fileName: String
    var filePath: String
    var content: String?
    var attriburedString: AttributedString?
    var needUpdate = true
    var isNotebookExists = true
    // UI optimazation related
    var editorView: EditorView = EditorView()
    var height: CGFloat = 0
    var isConfigured = false
    var themeID: UUID = UUID()
    var width: CGFloat = 0
}

extension Timeline: Equatable {
    
}

extension Timeline {
    
    mutating func updateWithTheme(theme: MarkdownTheme) async {
        
        // generate attribured string
        let markdownAttrStr = MarkdownAttriburedString(theme: theme)
        let newAttS = markdownAttrStr.getAttriburedString(forMarkdown: self.content!)
        self.attriburedString = AttributedString(newAttS)
    }

    var isRefreshRequired: Bool {
        (themeID != editorView.theme.id) || (width != editorView.textView.intrinsicContentSize.width)
    }
}
