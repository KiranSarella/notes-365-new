//
//  EditorUI.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

import SwiftUI

struct PreviewViewUI: UIViewRepresentable {
    
    let theme: MarkdownTheme = ThemeState.shared.theme
    let text: String
    var editorView: EditorView
    var editorType = EditorType.smart
    var isConfigured = false
   
    func makeUIView(context: Context) -> EditorView {
        
//        print(#function, isConfigured)
        
        if isConfigured {
            return editorView
        }
        
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
    
    func updateUIView(_ editorView: EditorView, context: Context) {

    }
    
    typealias NSViewType = EditorView
}

/// for timeline
//struct ReadOnlyMarkDownViewTwo: View {
//    
//    var timelineData: Timeline
//    @State private var timeline: Timeline
//    
//    var body: some View {
//        
//        PreviewViewUI(text: timeline.content ?? "no content",
//                     editorView: timeline.editorView,
//                      isConfigured: timeline.isConfigured
//        )
//        .frame(height: timeline.height)
//        .onAppear {
//            
//            if timeline.isConfigured && timeline.isRefreshRequired == false {
//                return
//            }
//            
//            Task {
//                DispatchQueue.main.async {
//                    timeline.editorView.textView.sizeToFit()
//                    timeline.height = timeline.editorView.textView.intrinsicContentSize.height + 80
//                    // refresh purpose
//                    timeline.themeID = timeline.editorView.theme.id
//                    timeline.width = timeline.editorView.textView.intrinsicContentSize.width
//                    timeline.isConfigured = true
//    //                print("height: ", height)
//    //                print("contentSize: ", timeline.editorView.textView.contentSize)
//    //                print("intrinsicContentSize: ", timeline.editorView.textView.intrinsicContentSize)
//                }
//            }
//            
//            
//        }
//        
//    }
//}

