//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorUI: UIViewRepresentable {
    
    let theme: MarkdownTheme
    let text: String
    @Binding var editorView: EditorView
    @Binding var contentEditedDate: Date?
    
    func makeUIView(context: Context) -> EditorView {
        editorView.theme = theme
        editorView.editorType = .smart
        editorView.textView.delegate = context.coordinator
        editorView.textView.font = theme.font
        editorView.textView.textColor = theme.bodyColor.uiColor
        editorView.textView.keyboardDismissMode = .interactive
        // line height
        // https://developer.apple.com/forums/thread/711814
        var attributes = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        paragraphStyle.lineHeightMultiple = 1.1
        paragraphStyle.lineSpacing = 10
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        editorView.textView.typingAttributes = attributes
        // set content
        editorView.textView.text = text

        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {

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


extension EditorUICoordinator: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        parent.contentEditedDate = Date()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        parent.contentEditedDate = Date()
    }
    
//    func textViewDidChangeSelection(_ textView: UITextView) {
//
//    }
    
}
