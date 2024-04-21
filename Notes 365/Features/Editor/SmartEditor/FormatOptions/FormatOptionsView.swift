//
//  FormatOptionsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI

struct FormattingOptionsView: View {
    @Binding var editorView: UIEditorView
    @Binding var contentEditedDate: Date?
    @State private var enableEraser = false
    
    private let buttonHeight: CGFloat = 20
    private let groupPadding: CGFloat = 30
    
//    var canUndo: Bool {
//        true
////        editorView.undoManager?.canUndo ?? false
//    }
//    
//    var canRedo: Bool {
//        true
////        editorView.undoManager?.canRedo ?? false
//    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Spacer()
                // bold, italic..
                HStack {
                    Group {
                        Button {
                            // make selected range as bold
                            editorView.markBold()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "bold")
                                .frame(width: 28, height: buttonHeight)
                                .help("Bold")
                        }
                        .keyboardShortcut("b")
                        
                        Button {
                            // make selected range as italic
                            editorView.markItalic()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "italic")
                                .frame(width: 28, height: buttonHeight)
                                .help("Italic")
                        }
                        .keyboardShortcut("i")
                        
                        Button {
                            editorView.markStrikethrough()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "strikethrough")
                                .frame(width: 28, height: buttonHeight)
                                .help("Strikethrough")
                        }
                        .keyboardShortcut("d")
                    }
                }
                // Headings
                HStack {
                    Menu {
                        Group {
                            Button {
                                editorView.heading(textStyle: .h1)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text(MarkdownHeading.h1.title)
                            }
//                            .keyboardShortcut("1", modifiers: [.command, .option])
                            
                            Button {
                                editorView.heading(textStyle: .h2)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text(MarkdownHeading.h2.title)
                            }
//                            .keyboardShortcut("2", modifiers: [.command, .option])
                            
                            Button {
                                editorView.heading(textStyle: .h3)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text(MarkdownHeading.h3.title)
                            }
//                            .keyboardShortcut("3", modifiers: [.command, .option])
                            
                            Button {
                                editorView.heading(textStyle: .h4)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text(MarkdownHeading.h4.title)
                            }
//                            .keyboardShortcut("4", modifiers: [.command, .option])
                        }
                    } label: {
                        Text("Headings")
                            .fontWeight(.bold)
                            .padding(.trailing, 40)
                            .frame(height: buttonHeight)
                    }
                }
                .padding([.leading], groupPadding)
                
                // quote and highlight
                HStack {
                    Group {
                        // quote
                        Button {
                            editorView.markBlockQuote()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "text.quote")
                                .frame(width: 28, height: buttonHeight)
                                .help("Quote Block")
                        }
                        // highlight
                        Button {
                            // make selected range as highlight
                            editorView.markHighlight()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "highlighter")
                                .frame(width: 28, height: buttonHeight)
                                .help("Highlight")
                        }
                    }
                }.padding([.leading], groupPadding)
                
                // code and code block
                HStack {
                    Group {
                        // code
                        Button {
                            editorView.markInline()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image("inline_code")
                                .resizable()
                                .frame(width: 28, height: buttonHeight)
                                .help("Inline Code")
                        }
                        // code block
                        Button {
                            editorView.markCodeblock()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .frame(width: 28, height: buttonHeight)
                                .help("Source Code")
                        }
                        
                    }
                }
                .padding([.leading], groupPadding)
                
                HStack {
                    Divider().frame(height: 28)
                }
                .padding([.leading], groupPadding)
                
                
                HStack {
                    Group {
                        Button {
                            // make selected range as bold
                            editorView.performUndo()
                            contentEditedDate = DateTime.now()
                            EditorOutputBuffer.shared.canUndo = editorView.textView.undoManager?.canUndo ?? false
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .frame(width: 28, height: buttonHeight)
                                .help("Undo")
                        }
                        .disabled(!EditorOutputBuffer.shared.canUndo)
                        
                        Button {
                            // make selected range as bold
                            editorView.performRedo()
                            contentEditedDate = DateTime.now()
                            EditorOutputBuffer.shared.canRedo = editorView.textView.undoManager?.canRedo ?? false
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .frame(width: 28, height: buttonHeight)
                                .help("Redo")
                        }
                        .disabled(!EditorOutputBuffer.shared.canRedo)
                    }
                }.padding([.leading], groupPadding)
                
                HStack {
                    Group {
                        // Clear
                        Button {
                            editorView.clearFormat()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "eraser.line.dashed")
                                .frame(width: 28, height: buttonHeight)
                                .help("Clear format")
                        }
                        .disabled(!enableEraser)
                    }
                }.padding([.leading], groupPadding)
                
                Spacer()
            }
            .padding(5)
        }
        .fontDesign(.rounded)
        .buttonStyle(.bordered)
        .onChange(of: EditorOutputBuffer.shared.selectedRange) { old, new in
            enableEraser = new.length > 3
        }
    }
    
}
