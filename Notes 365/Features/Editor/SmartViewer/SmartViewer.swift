//
//  SmartViewer.swift
//  Notes 365
//
//  Created by kiran ipc on 17/02/24.
//

import Foundation
import SwiftUI

struct SmartViewerRepresentable: UIViewRepresentable {
    let theme: MarkdownTheme = ThemeState.shared.theme

    @State private var editorView = UIEditorView()
    @Binding var content: String?
    @Binding var width: CGFloat
    @State var height: CGFloat = 100
    
    var editorType = EditorType.smart
    var isConfigured = false

    func makeUIView(context: Context) -> UIEditorView {
        logger.debug("SmartViewerRepresentable - \(#function)")
        editorView.editorType = EditorType.smart
        editorView.textView.font = theme.font
        editorView.textView.textColor = theme.bodyColor.uiColor
        
        var attributes = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineSpacing = 10
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        attributes[NSAttributedString.Key.font] = theme.font
        editorView.textView.typingAttributes = attributes
        
        editorView.textView.text = content
        editorView.setAsReadOnly()
        updateHeight()
        return editorView
    }
    
    func updateUIView(_ editorView: UIEditorView, context: Context) {
        logger.debug("SmartViewerRepresentable - \(#function)")
//        updateHeight()
    }
    
    typealias NSViewType = UIEditorView
    
    func updateHeight() {
        DispatchQueue.main.async {
            logger.debug("\(editorView.text)")
            editorView.textView.sizeToFit()
            let contentSizeHeight = editorView.textView.contentSize.height
            height = contentSizeHeight
            logger.debug("\(height)")
        }
        
        
//        Task {
//            try? await Task.sleep(nanoseconds: 700_000_000) // wait until attributed string prepared
//            DispatchQueue.main.async {
//                editorView.textView.sizeToFit()
//                let contentSizeHeight = editorView.textView.contentSize.height
//                height = contentSizeHeight
//            }
//        }
    }
}

