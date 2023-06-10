//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorViewUI: UIViewRepresentable {
    
    let theme: MarkdownTheme
    let text: String
    @Binding var editorView: EditorView
    @Binding var contentEditedDate: Date?
    let isEditable: Bool
    
    func makeUIView(context: Context) -> EditorView {
        editorView.theme = theme
        editorView.editorType = .smart
        editorView.textView.delegate = context.coordinator
        editorView.textView.font = theme.font
        editorView.textView.textColor = theme.bodyColor.uiColor
        editorView.textView.keyboardDismissMode = .interactive
        // line height
        // https://developer.apple.com/forums/thread/711814
        // or using layout manager (need to try)
        // https://stackoverflow.com/questions/3760924/set-line-height-in-uitextview
        var attributes = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        paragraphStyle.lineHeightMultiple = 1.1
        paragraphStyle.lineSpacing = 10
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        attributes[NSAttributedString.Key.font] = theme.font
        editorView.textView.typingAttributes = attributes
        // set content
        editorView.textView.text = text

        editorView.textView.isEditable = isEditable
        
        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {

    }
    
    typealias NSViewType = EditorView
}

extension EditorViewUI {
    func makeCoordinator() -> EditorUICoordinator {
        return EditorUICoordinator(self)
    }
}

// Define View Modifiers
class EditorUICoordinator: NSObject {
    var parent: EditorViewUI
    init(_ parent: EditorViewUI) {
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
    
}
