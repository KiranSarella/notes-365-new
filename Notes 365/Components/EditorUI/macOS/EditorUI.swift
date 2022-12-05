//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//


#if os(macOS)

import SwiftUI


struct EditorUI: NSViewRepresentable {
    var theme: MarkdownTheme
    @Binding var text: String
    @Binding var editorView: EditorView
    var currentTextStyleAction: (TextStyleKey?, Any, Bool)

//    var createdView: ((EditorView) -> ())? = nil
    
    var completion: (String) -> ()
    var actionCompleted: () -> ()
    
    func makeNSView(context: Context) -> EditorView {
//        let editorView = EditorView(theme: theme)
        editorView.theme = theme
        editorView.editorType = .smart
        editorView.textView.delegate = context.coordinator
        editorView.textView.font = theme.font
        editorView.textView.textColor = NSColor(theme.bodyColor.color)
        let paragraphStyle = NSMutableParagraphStyle()
        //            paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
        editorView.textView.defaultParagraphStyle = paragraphStyle
        editorView.textView.string = text
        
//        createdView?(editorView)
        
        return editorView
    }
    
    func updateNSView(_ nsView: EditorView, context: Context) {
        print(#function)

//        nsView.textView.string = text // ** cursor will move to end; so never do this

        // ** change type commands -- then only updated action will be executed.. try it.

//        print("currentTextStyleAction: ", currentTextStyleAction.0)

        switch currentTextStyleAction.0 {
        case .bold:
            nsView.markBold {
                self.completion(nsView.textView.string)
            }

        case .italic:
            nsView.markItalic {
                self.completion(nsView.textView.string)
            }

        case .strikethrough:
            nsView.markStrikethrough {
                self.completion(nsView.textView.string)
            }

        case .font:

            nsView.headingFontChanged(fontName: currentTextStyleAction.1 as! String) {
//                self.completion(nsView.textView.string)
            }
            
           break
        case .none:
            break
        case .fontSizeBigger:

           break
        case .fontSizeSmaller:

           break
        case .getContent:

//            print(nsView.textView.string, "\n")
//
//            print(nsView.textView.attributedString())

            completion(nsView.textView.string)

        case .editorType:
            // editor type (smart, markdown)
            let newMode = currentTextStyleAction.1 as! EditorType
            if nsView.editorType != newMode {
                nsView.editorType = newMode
            }
//            nsView.editorType = currentTextStyleAction.1 as! EditorType

        case .clear:
            nsView.clearFormat {
                self.completion(nsView.textView.string)
            }

        case .h1:
            nsView.heading(textStyle: .h1)  {
                self.completion(nsView.textView.string)
            }
        case .h2:
            nsView.heading(textStyle: .h2) {
                self.completion(nsView.textView.string)
            }
        case .h3:
            nsView.heading(textStyle: .h3) {
                self.completion(nsView.textView.string)
            }
        case .h4:
            nsView.heading(textStyle: .h4) {
                self.completion(nsView.textView.string)
            }
        case .h5:
            nsView.heading(textStyle: .h5) {
                self.completion(nsView.textView.string)
            }
        case .h6:
            nsView.heading(textStyle: .h6) {
                self.completion(nsView.textView.string)
            }


        case .link:
            break
        case .image:
            nsView.insertImage {
                self.completion(nsView.textView.string)
            }

        case .inline:
            nsView.markInline {
                self.completion(nsView.textView.string)
            }
        case .codeBlock:
            nsView.markCodeblock {
                self.completion(nsView.textView.string)
            }
        case .textUpdate:
//            print("TEXT UPDATE")
            nsView.textView.string = self.text
            actionCompleted()
        case .theme:
            let theme = currentTextStyleAction.1 as! MarkdownTheme
            nsView.updateTheme(theme: theme) {
                //
            }
        case .blockQuote:
            nsView.markBlockQuote {
                self.completion(nsView.textView.string)
            }
        }
    }
    
    
    typealias NSViewType = EditorView
}

extension EditorUI {
    
    func makeCoordinator() -> EditorUICoordinator {
        
        return EditorUICoordinator(self, text: $text)
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
    @Binding var text: String
    
    init(_ parent: EditorUI, text: Binding<String>) {
        self.parent = parent
        _text = text
    }
}


extension EditorUICoordinator: NSTextViewDelegate {
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else {
            return
        }
        
        // Update text
//        self.parent.$text.wrappedValue = textView.string
        
//        text = textView.string
        
//        self.parent.completion(textView.string)
    }
    
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        
        
        return true
    }
    
}

#endif
