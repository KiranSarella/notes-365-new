//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorViewUI: UIViewRepresentable {
    let theme: MarkdownTheme = ThemeState.shared.theme
    @Binding var output: String
    @Binding var text: String
    @Binding var editorView: EditorView
    @Binding var contentEditedDate: Date?
    let isEditable: Bool
    var isEditor = true
    var width: CGFloat = 0
    var editorType = EditorType.smart
    var isConfigured = false
//    @Binding var height: CGFloat
    
    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
        guard let attrStr = attrStr else {
            return 100
        }
        let rect = attrStr.boundingRect(with: CGSize(width: width - 90, height: 10000), options: [.usesLineFragmentOrigin], context: nil)
        return ceil(rect.size.height) + 50
//        return rect.height + 50
    }
    
    func makeUIView(context: Context) -> EditorView {
        print(#function)
        if isConfigured {
            return editorView
        }
//        print(#function)
//        editorView.width = width
//        editorView.theme = theme
        editorView.editorType = editorType
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
            // calc height
//            DispatchQueue.main.async {
//                height = calculateHeight(editorView.textView.attributedText, width: width)
//                print("calc: ", width, height)
//                print("content size: ", editorView.textView.contentSize)
//            }
        }
        
        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {
//        print(#function)
    }
    
    typealias NSViewType = EditorView
}

extension EditorViewUI {
    func makeCoordinator() -> EditorUICoordinator {
        return EditorUICoordinator(self, output: $output)
    }
}

// Define View Modifiers
class EditorUICoordinator: NSObject {
    var parent: EditorViewUI
    @Binding var output: String
    
    init(_ parent: EditorViewUI, output: Binding<String>) {
        self.parent = parent
        _output = output
    }
}

extension EditorUICoordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        output = textView.text
        parent.contentEditedDate = DateTime.now()
    }
}

struct ReadOnlyMarkDownView: View {
    @State var editorView = EditorView()
    var content: String?
//    var width: CGFloat
    @State var height: CGFloat = 100
    var body: some View {
        EditorViewUI(output: Binding.constant(""), text: Binding.constant(content ?? "no content"),
                     editorView: $editorView,
                     contentEditedDate: Binding.constant(DateTime.now()),
                     isEditable: false,
                     isEditor: false
        )
        .onAppear {
            DispatchQueue.main.async {
                editorView.textView.sizeToFit()
                height = editorView.textView.contentSize.height
            }
        }
        .frame(height: height)
    }
}

extension NSAttributedString {

    func height(for containerWidth: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }

    func width(for containerHeight: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width)
    }
}
