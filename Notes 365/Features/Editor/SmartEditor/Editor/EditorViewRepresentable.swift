//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorViewRepresentable: UIViewRepresentable {
    let theme: MarkdownTheme = ThemeState.shared.theme
    let text: String
    var editorView: UIEditorView
    @Binding var contentEditedDate: Date?
    
    let isEditable: Bool
    var isEditor = true
    var width: CGFloat = 0
    var editorType = EditorType.smart
    var isConfigured = false

    func makeUIView(context: Context) -> UIEditorView {
//        logger.debug("\(#function)")
//        logger.debug("\(text)")
        if isConfigured {
            return editorView
        }
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

        if isEditor {
            editorView.setAsEditor(isEditable: isEditable)
        } else {
            editorView.setAsReadOnly()
        }
        
        return editorView
    }
    
    func updateUIView(_ editorView: UIEditorView, context: Context) {
//        logger.debug("\(#function)")
    }
    
    typealias NSViewType = UIEditorView
}

extension EditorViewRepresentable {
    func makeCoordinator() -> EditorUICoordinator {
        return EditorUICoordinator(self)
    }
}

// Define View Modifiers
class EditorUICoordinator: NSObject {
    var parent: EditorViewRepresentable
    
    init(_ parent: EditorViewRepresentable) {
        self.parent = parent
    }
}

extension EditorUICoordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        DispatchQueue.main.async {
//            self.output = textView.text
//        }
        EditorOutputBuffer.shared.output = textView.text
        parent.contentEditedDate = DateTime.now()
        EditorOutputBuffer.shared.canUndo = textView.undoManager?.canUndo ?? false
        EditorOutputBuffer.shared.canRedo = textView.undoManager?.canRedo ?? false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        EditorOutputBuffer.shared.selectedRange = textView.selectedRange
    }
}

struct ReadOnlyMarkDownView: View {
    @State var editorView = UIEditorView()
    @Binding var content: String?
    @Binding var width: CGFloat
    @State var height: CGFloat = 100
    
    @State var editedDate: Date? = DateTime.now()
    
    var body: some View {
        EditorViewRepresentable(text: content ?? "no content",
                     editorView: editorView,
                     contentEditedDate: $editedDate,
                     isEditable: false,
                     isEditor: false
        )
        .onAppear {
            updateHeight()
        }
        .frame(height: height)
        .onChange(of: width) { oldValue, newValue in
            updateHeight()
        }
        .onChange(of: ThemeState.shared.theme) { oldValue, newValue in
            updateHeight()
        }
        .onChange(of: content) { oldValue, newValue in
//            editedDate = DateTime.now()
//            logger.debug("\(newValue ?? "")")
            editorView.textView.text = newValue ?? ""
        }
    }
    
    func updateHeight() {
        Task { @MainActor in
            let sec = UInt64.random(in: 700_000_000..<1200_000_000)
//            logger.debug("random seconds: \(sec)")
            try? await Task.sleep(nanoseconds: sec) // wait until attributed string prepared
//            DispatchQueue.main.async {
                editorView.textView.sizeToFit()
                let contentSizeHeight = editorView.textView.contentSize.height
                height = contentSizeHeight
//            }
        }
    }
    
//    func heightForAttributedString(_ attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.attributedText = attributedString
//        label.sizeToFit()
//        return label.frame.height
//    }

}

extension NSAttributedString {

    func height(for containerWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
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



struct SmartDocViewerRepresentable: UIViewRepresentable {
    let theme: MarkdownTheme = ThemeState.shared.theme
    let text: String
    
    @Binding var contentEditedDate: Date?
//    var editorView: UIEditorView
    let isEditable: Bool
    var isEditor = true
    var width: CGFloat = 0
    var editorType = EditorType.smart
    var isConfigured = false

    func makeUIView(context: Context) -> UIEditorView {
//        logger.debug("\(#function)")
//        logger.debug("\(text)")
        let editorView = UIEditorView()
        editorView.editorType = editorType
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

        editorView.setAsReadOnly()
        return editorView
    }
    
    func updateUIView(_ editorView: UIEditorView, context: Context) {
        logger.debug("\(#function)")
    }
    
    typealias NSViewType = UIEditorView
}
