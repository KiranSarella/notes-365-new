//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct EditorViewUI: UIViewRepresentable {
    
    let theme: MarkdownTheme = ThemeState.shared.theme
    let text: String
    @Binding var editorView: EditorView
    @Binding var contentEditedDate: Date?
    let isEditable: Bool
    var isEditor = true
    var width: CGFloat = 0
    var editorType = EditorType.smart
    @Binding var height: CGFloat
    
    func heightForView(attrtext:NSAttributedString, width:CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.attributedText = attrtext
        label.sizeToFit()
        print("label.frame: ", label.frame)
        return label.frame.height
    }
    
    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
        guard let attrStr = attrStr else {
            return 100
        }
        let rect = attrStr.boundingRect(with: CGSize(width: width - 90, height: 10000), options: [.usesLineFragmentOrigin], context: nil)
        return rect.height + 50
    }
    
    func makeUIView(context: Context) -> EditorView {
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
            DispatchQueue.main.async {
                height = calculateHeight(editorView.textView.attributedText, width: width)
            }
        }
        
        return editorView
    }
    
    func updateUIView(_ editorView: EditorView, context: Context) {
//        editorView.textView.sizeToFit()
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

// MARK: - Modifier
//
//struct SetDisplayWithAttr: ViewModifier {
//    
//    fileprivate func calculateHeight(_ attrStr: NSAttributedString?, width: CGFloat) -> CGFloat {
//        guard let attrStr = attrStr else {
//            return 100
//        }
//        
////        print("width: ", width)
//        let rect = attrStr.boundingRect(with: CGSize(width: width, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
////        print("rect: ", rect)
//        return rect.height + 50
//    }
//    
//    let width: CGFloat
//    let attrStr: NSAttributedString?
//    
//    func body(content: Content) -> some View {
//        content.frame(height: calculateHeight(attrStr, width: width))
//    }
//}
//
//extension EditorViewUI {
//    
//    func setDisplay(width: CGFloat) -> some View {
//        modifier(SetDisplayWithAttr(width: width, attrStr: self.editorView.textView.attributedText))
//    }
//}


struct ReadOnlyMarkDownView: View {
    
    @State var editorView = EditorView()
    var content: String?
    var width: CGFloat
    @State var height: CGFloat = 100
    
    var body: some View {
        
        EditorViewUI(text: content ?? "no content",
                     editorView: $editorView,
                     contentEditedDate: Binding.constant(Date()),
                     isEditable: false,
                     isEditor: false,
                     width: width,
                     height: $height
        )
        .frame(height: height)
    }
}


struct ReadOnlySymbolsView: View {
    
    @State var editorView = EditorView()
    var content: String?
    var width: CGFloat
    @State var height: CGFloat = 100
    @Binding var editorType: EditorType
    
    var body: some View {
        
        EditorViewUI(text: content ?? "no content",
                     editorView: $editorView,
                     contentEditedDate: Binding.constant(Date()),
                     isEditable: false,
                     isEditor: false,
                     width: width,
                     editorType: editorType, height: $height
        )
        .onAppear {
            editorView.textView.backgroundColor = .clear
        }
        .frame(height: height)
        .onChange(of: editorType) { newValue in
            editorView.editorType = newValue
        }
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
