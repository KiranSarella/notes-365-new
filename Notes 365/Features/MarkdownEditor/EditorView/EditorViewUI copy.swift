//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorViewUI2: UIViewRepresentable {
    
    let theme: MarkdownTheme
    let text: String
    let editorView = EditorView()
    let isEditable: Bool
    var isEditor = true
    var width: CGFloat
    @Binding var height: CGFloat
    
//    var changeHandler: (()->())?
    
    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
        guard let attrStr = attrStr else {
            return 100
        }
        
        print("width: ", width)
        let rect = attrStr.boundingRect(with: CGSize(width: width - 100, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
//        print("rect: ", rect)
        return rect.height + 50
    }
    
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

//        editorView.textView.isEditable = isEditable
        
        if isEditor {
            editorView.setAsEditor(isEditable: isEditable)
        } else {
            editorView.setAsReadOnly()
        }
        
        DispatchQueue.main.async {
            height = calculateHeight(editorView.textView.attributedText, width: width)
        }
        
        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {
        
    }
    
    typealias NSViewType = EditorView
}

extension EditorViewUI2 {
    func makeCoordinator() -> EditorUICoordinator2 {
        return EditorUICoordinator2(self)
    }
}

// Define View Modifiers
class EditorUICoordinator2: NSObject {
    var parent: EditorViewUI2
    init(_ parent: EditorViewUI2) {
        self.parent = parent
    }
}


extension EditorUICoordinator2: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        parent.contentEditedDate = Date()
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        parent.contentEditedDate = Date()
//        parent.changeHandler?()
    }
    
}

// MARK: - Modifier

struct SetDisplayWithAttr: ViewModifier {
    
    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
        guard let attrStr = attrStr else {
            return 100
        }
        
//        print("width: ", width)
        let rect = attrStr.boundingRect(with: CGSize(width: width, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
//        print("rect: ", rect)
        return rect.height + 50
    }
    
    let width: CGFloat
    let attrStr: NSAttributedString?
    
    func body(content: Content) -> some View {
        content.frame(height: calculateHeight(attrStr, width: width))
    }
}

extension EditorViewUI2 {
    
    func setDisplay(width: CGFloat) -> some View {
        modifier(SetDisplayWithAttr(width: width, attrStr: self.editorView.textView.attributedText))
    }
//
//    func onContentChange(completion:@escaping (() -> ())) -> some View {
//
//        self.changeHandler = completion
//
//        return modifier(EmptyModifier())
//    }
//
}


struct ReadOnlyMarkDownView2: View {
    
    var content: String?
    @Binding var theme: MarkdownTheme
    var width: CGFloat
    @State var height: CGFloat = 100
    
    var body: some View {
        EditorViewUI2(theme: theme,
                     text: content ?? "no content",
                     isEditable: false,
                      isEditor: false, width: width, height: $height)
        .frame(height: height)
    }
}
