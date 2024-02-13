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
//    @Binding var height: CGFloat
    
    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
        guard let attrStr = attrStr else {
            return 100
        }
        let rect = attrStr.boundingRect(with: CGSize(width: width - 90, height: 10000), options: [.usesLineFragmentOrigin], context: nil)
        return ceil(rect.size.height) + 50
//        return rect.height + 50
    }
    
    func makeUIView(context: Context) -> UIEditorView {
//        logger.debug("\(#function)")
//        logger.debug("\(text)")
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
    
    func updateUIView(_ editorView: UIEditorView, context: Context) {
//        print(#function)
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
    var content: String?
    @Binding var width: CGFloat
    @State var height: CGFloat = 100
    var body: some View {
        EditorViewRepresentable(text: content ?? "no content",
                     editorView: editorView,
                     contentEditedDate: Binding.constant(DateTime.now()),
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
    }
    
    func updateHeight() {
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000) // wait until attributed string prepared
            DispatchQueue.main.async {
                editorView.textView.sizeToFit()
                let contentSizeHeight = editorView.textView.contentSize.height
                height = contentSizeHeight
            }
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
