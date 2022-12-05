//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//


#if os(macOS)

import SwiftUI

struct EditorUI: NSViewRepresentable {
    let theme: MarkdownTheme
    let text: String
    @Binding var editorView: EditorView
    @Binding var contentEdited: Bool
    
    func makeNSView(context: Context) -> EditorView {
        editorView.theme = theme
        editorView.editorType = .smart
        editorView.textView.delegate = context.coordinator
        editorView.textView.font = theme.font
        editorView.textView.textColor = NSColor(theme.bodyColor.color)
        let paragraphStyle = NSMutableParagraphStyle()
        //            paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
        editorView.textView.defaultParagraphStyle = paragraphStyle
        editorView.textView.string = text
        
        return editorView
    }
    
    func updateNSView(_ nsView: EditorView, context: Context) {
        
    }
    
    typealias NSViewType = EditorView
}

extension EditorUI {
    func makeCoordinator() -> EditorUICoordinator {
        return EditorUICoordinator(self)
    }
}

// Define View Modifiers
class EditorUICoordinator: NSObject {
    var parent: EditorUI
    init(_ parent: EditorUI) {
        self.parent = parent
    }
}

extension EditorUICoordinator: NSTextViewDelegate {
    func textDidBeginEditing(_ notification: Notification) {
        parent.contentEdited = true
    }
}

#endif
