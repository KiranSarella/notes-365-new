//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

#if os(iOS)

import SwiftUI


struct EditorUI: UIViewRepresentable {
    
//    var editorType: EditorType

    var theme: MarkdownTheme
    
    @Binding var text: String
    
    var currentTextStyleAction: (TextStyleKey?, Any, Bool)

    var completion: (String) -> ()
    var actionCompleted: () -> ()
    
//    var commandStr: String = ""
    
    
    func makeUIView(context: Context) -> EditorView {
        
        let editorView = EditorView(theme: theme)
        
        editorView.editorType = .smart
        
        editorView.textView.delegate = context.coordinator
        
        editorView.textView.font = theme.font
        editorView.textView.textColor = UIColor(theme.bodyColor.color)
        
        let paragraphStyle = NSMutableParagraphStyle()
        //            paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
//        editorView.textView.defaultParagraphStyle = paragraphStyle
        
        editorView.textView.text = text
        
//        editorView.resetText(text: text)
        
//        editorView.textView.text = "makeUIView .. text update"
        
        return editorView
    }
    
//    func updateNSView(_ nsView: EditorView, context: Context) { }
    
    func updateUIView(_ nsView: EditorView, context: Context) {
//        print(#function)

//        nsView.textView.text = text // ** cursor will move to end; so never do this

        // ** change type commands -- then only updated action will be executed.. try it.

//        print("currentTextStyleAction: ", currentTextStyleAction.0)

        switch currentTextStyleAction.0 {
        case .bold:
            nsView.markBold {
                self.completion(nsView.textView.text)
            }

        case .italic:
            nsView.markItalic {
                self.completion(nsView.textView.text)
            }

        case .strikethrough:
            nsView.markStrikethrough {
                self.completion(nsView.textView.text)
            }

        case .font:

            nsView.headingFontChanged(fontName: currentTextStyleAction.1 as! String) {
//                self.completion(nsView.textView.text)
            }
            
           break
        case .none:
            break
        case .fontSizeBigger:

           break
        case .fontSizeSmaller:

           break
        case .getContent:

//            print(nsView.textView.text, "\n")
//
//            print(nsView.textView.attributedString())

            completion(nsView.textView.text)

        case .editorType:
            // editor type (smart, markdown)
            let newMode = currentTextStyleAction.1 as! EditorType
            if nsView.editorType != newMode {
                nsView.editorType = newMode
            }
//            nsView.editorType = currentTextStyleAction.1 as! EditorType

        case .clear:
            nsView.clearFormat {
                self.completion(nsView.textView.text)
            }

        case .h1:
            nsView.heading(textStyle: .h1)  {
                self.completion(nsView.textView.text)
            }
        case .h2:
            nsView.heading(textStyle: .h2) {
                self.completion(nsView.textView.text)
            }
        case .h3:
            nsView.heading(textStyle: .h3) {
                self.completion(nsView.textView.text)
            }
        case .h4:
            nsView.heading(textStyle: .h4) {
                self.completion(nsView.textView.text)
            }
        case .h5:
            nsView.heading(textStyle: .h5) {
                self.completion(nsView.textView.text)
            }
        case .h6:
            nsView.heading(textStyle: .h6) {
                self.completion(nsView.textView.text)
            }


        case .link:
            break
        case .image:
            nsView.insertImage {
                self.completion(nsView.textView.text)
            }

        case .inline:
            nsView.markInline {
                self.completion(nsView.textView.text)
            }
        case .codeBlock:
            nsView.markCodeblock {
                self.completion(nsView.textView.text)
            }
        case .textUpdate:
//            print("TEXT UPDATE")
            nsView.textView.text = text
//            nsView.resetText(text: text)
            
//            nsView.textView.textStorage.beginEditing()
//            nsView.textView.textStorage.setAttributedString(NSAttributedString(string: self.text))
//            nsView.textView.textStorage.endEditing()
            
//            nsView.textView.textStorage.setAttributedString(NSAttributedString(string: self.text))
            
//            nsView.textView.attributedText = NSAttributedString(string: self.text)
            
//            nsView.textView.text = self.text // textView.text = self.text
            actionCompleted()
        case .theme:
            let theme = currentTextStyleAction.1 as! MarkdownTheme
            nsView.updateTheme(theme: theme) {
                //
            }
        case .blockQuote:
            nsView.markBlockQuote {
                self.completion(nsView.textView.text)
            }
        }
    }
    
    
    typealias NSViewType = EditorView
}

extension EditorUI {
    
    func makeCoordinator() -> EditorUICoordinator {
        
        return EditorUICoordinator(self)
    }
    
//    public func formatCommand(str: String) -> Self {
//        print(str)
//        let view = self
//        view.commandStr = str
//
//        return view
//    }
}

// Define View Modifiers
class EditorUICoordinator: NSObject {
    
    var parent: EditorUI
    
    
    
    init(_ parent: EditorUI) {
        self.parent = parent
    }
    
}


extension EditorUICoordinator: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let text = textView.attributedText.string
        
        self.parent.completion(text)
        
//        if text == nil {
//            self.parent.completion("")
//        } else {
//
//        }
//
       
        
    }
    
//    func textDidChange(_ notification: Notification) {
//        guard let textView = notification.object as? NSTextView else {
//            return
//        }
//
//        // Update text
////        self.parent.$text.wrappedValue = textView.text
//
//
//        self.parent.completion(textView.text)
//    }
//
    
//    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
//
//
//        return true
//    }
    
}

#endif
