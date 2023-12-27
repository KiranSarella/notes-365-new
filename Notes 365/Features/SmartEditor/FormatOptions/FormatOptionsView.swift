//
//  FormatOptionsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI

struct FormattingOptionsView: View {
    @Binding var editorView: EditorView
    @Binding var contentEditedDate: Date?
    @Binding var selectedRange: NSRange
    @State private var enableEraser = false
    private let buttonHeight: CGFloat = 20
    private let groupPadding: CGFloat = 30
    
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
                        Button {
                            // make selected range as italic
                            editorView.markItalic()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "italic")
                                .frame(width: 28, height: buttonHeight)
                                .help("Italic")
                        }
                        Button {
                            editorView.markStrikethrough()
                            contentEditedDate = DateTime.now()
                        } label: {
                            Image(systemName: "strikethrough")
                                .frame(width: 28, height: buttonHeight)
                                .help("Strikethrough")
                        }
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
                                Text("Large Title")
                            }
                            Button {
                                editorView.heading(textStyle: .h2)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text("Title")
                            }
                            Button {
                                editorView.heading(textStyle: .h3)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text("Title 2")
                            }
                            Button {
                                editorView.heading(textStyle: .h4)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text("Title 3")
                            }
                            Button {
                                editorView.heading(textStyle: .h5)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text("Heading")
                            }
                            Button {
                                editorView.heading(textStyle: .h6)
                                contentEditedDate = DateTime.now()
                            } label: {
                                Text("Subheading")
                            }
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
                Spacer()
                
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
            }
            .padding(5)
        }
        .fontDesign(.rounded)
        .buttonStyle(.bordered)
        .onChange(of: selectedRange) { old, new in
            enableEraser = new.length > 3
        }
    }
    
}
