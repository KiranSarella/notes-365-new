//
//  EditTimelineView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/04/24.
//

import SwiftUI


struct EditTimelineView: View {
    let timeline: Timeline
    @Binding var presentEditTimelineView: Bool
    
    @State private var editorView = UIEditorView()
    @State private var showSymbols = false
    @State private var editorType = EditorType.smart
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
//                HStack {
                    FormattingOptionsView(editorView: $editorView, contentEditedDate: .constant(nil))
                        .padding(.horizontal)
                        .backgroundStyle(.regularMaterial)
                        .background(.background)
                    
//                    Spacer()
//                    HStack {
//                        
//                            .padding()
//                    }
//                    .frame(maxWidth: 70)
//                }
                
                
                EditorViewRepresentable(text: timeline.content ?? "", editorView: editorView, contentEditedDate: .constant(nil),  isEditable: true)
                    .font(Font.body)
    //                .focused($isTextFieldFocused)
                    .lineSpacing(EditorSettings.lineSpacing)
            }
            .toolbar(content: {
                
                
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentEditTimelineView = false
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                // mode change
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("", isOn: $showSymbols)
                        .toggleStyle(.switch)
                        .help(showSymbols == false ? "Show Symbols" : "Hide Symbols")
                        .onChange(of: showSymbols, { oldValue, newValue in
                            if newValue {
                                editorType = .markdown
                            } else {
                                editorType = .smart
                            }
                            editorView.editorType = editorType
                        })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Text("Update")
                    })
                }
                
                
            })
        }
//        .frame(width: 1600, height: 900)
    }
}

