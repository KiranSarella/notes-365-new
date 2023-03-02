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
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //            paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
//        editorView.textView.defaultParagraphStyle = paragraphStyle
        editorView.textView.text = text
        editorView.textView.textStorage.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: editorView.textView.textStorage.fullRange())

        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 10
//        editorView.textView.textStorage.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: editorView.textView.textStorage.fullRange())
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
    
}
