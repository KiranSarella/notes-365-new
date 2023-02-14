//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

#if os(iOS)
import SwiftUI

struct EditorUI: UIViewRepresentable {
    
    let theme: MarkdownTheme
    let text: String
    @Binding var editorView: EditorView
    @Binding var contentEdited: Bool
    
    func makeUIView(context: Context) -> EditorView {
//
//        let editorView = EditorView(theme: theme)
//
//        editorView.editorType = .smart
//
//        editorView.textView.delegate = context.coordinator
//
//        editorView.textView.font = theme.font
//        editorView.textView.textColor = UIColor(theme.bodyColor.color)
//
////        let paragraphStyle = NSMutableParagraphStyle()
//        //            paragraphStyle.minimumLineHeight = 10
////        paragraphStyle.lineSpacing = 10
////        editorView.textView.defaultParagraphStyle = paragraphStyle
//
//        editorView.textView.text = text
//
////        editorView.resetText(text: text)
//
////        editorView.textView.text = "makeUIView .. text update"
//
//        return editorView
//
        
        editorView.theme = theme
        editorView.editorType = .smart
        editorView.textView.delegate = context.coordinator
        editorView.textView.font = theme.font
        editorView.textView.textColor = theme.bodyColor.uiColor
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //            paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
//        editorView.textView.defaultParagraphStyle = paragraphStyle
        
        
        editorView.textView.text = text
        
        
        editorView.textView.textStorage.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: editorView.textView.textStorage.fullRange())
//
//        editorView.textStorage.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: editorView.textStorage.fullRange())
//
        
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
        parent.contentEdited = true
    }
}

#endif
