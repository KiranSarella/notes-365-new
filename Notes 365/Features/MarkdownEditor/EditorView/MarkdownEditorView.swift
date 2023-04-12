//
//  MarkdownEditorView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/04/23.
//

import SwiftUI

struct MarkdownEditorView: View {
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var editorView = EditorView()
    
    @State private var editorType = EditorType.smart
    @State private var showSymbols = false
    
    @Binding var contentEditedDate: Date?
    @Binding var theme: MarkdownTheme
    @Binding var baseContent: String
    
    var handler: (( @escaping () -> String) -> ())
    
    var body: some View {
        
        VStack(alignment: .leading) {
            // formatting bar view
            FormattingOptionsView(editorView: $editorView, contentEditedDate: $contentEditedDate)
                .padding(.horizontal)
                .backgroundStyle(.regularMaterial)
                .background(.background)
            
            EditorViewUI(theme: theme, text: baseContent, editorView: $editorView, contentEditedDate: $contentEditedDate)
                .font(Font.body)
                .focused($isTextFieldFocused)
        }
        .onAppear {
            
            handler({
                return editorView.text
            })
            
//            handler = {
//                return editorView.text
//            }
            
//            getText(editorView.text)
        }
        .onChange(of: theme, perform: { newValue in
            editorView.updateTheme(theme: theme)
        })
        .onChange(of: baseContent, perform: { newValue in
            isTextFieldFocused = false
            showSymbols = false
            self.contentEditedDate = nil
            
            editorView.text = newValue
        })
        .onDisappear {
            isTextFieldFocused = false
        }
        .toolbar {
            
            Button {
                editorView.findAction()
            } label: {
                Image(systemName: "magnifyingglass")
            }
            .foregroundColor(.primary)
            
            Toggle("Mode", isOn: $showSymbols)
                .toggleStyle(.switch)
                .help(showSymbols == false ? "Show Symbols" : "Hide Symbols")
                .onChange(of: showSymbols) { newValue in
                    if newValue {
                        editorType = .markdown
                    } else {
                        editorType = .smart
                    }
                    
                    editorView.editorType = editorType
                }
        }
        .pickerStyle(SegmentedPickerStyle())
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}

//struct MarkdownEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        MarkdownEditorView()
//    }
//}
