//
//  FormatOptionsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI


struct FormattingOptionsView: View {
    @Binding var editorView: EditorView
    
    var body: some View {
        HStack {
            Spacer()
            // bold, italic..
            HStack {
                Group {
                    Button {
                        // make selected range as bold
                        editorView.markBold()
                    } label: {
                        Image(systemName: "bold")
                            .help("Bold")
                    }
                    Button {
                        // make selected range as italic
                        editorView.markItalic()
                    } label: {
                        Image(systemName: "italic")
                            .help("Italic")
                    }
                    Button {
                        editorView.markStrikethrough()
                    } label: {
                        Image(systemName: "strikethrough")
                            .help("Strikethrough")
                    }
                }
                .padding([.leading, .trailing], 10)
            }
            // H1,.. H6
            HStack {
                Group {
                    Button {
                        editorView.heading(textStyle: .h1)
                    } label: {
                        Text("H1")
                            .help("Heading 1")
                    }
                    Button {
                        editorView.heading(textStyle: .h2)
                    } label: {
                        Text("H2")
                            .help("Heading 2")
                    }
                    Button {
                        editorView.heading(textStyle: .h3)
                    } label: {
                        Text("H3")
                            .help("Heading 3")
                    }
                    Button {
                        editorView.heading(textStyle: .h4)
                    } label: {
                        Text("H4")
                            .help("Heading 4")
                    }
                    Button {
                        editorView.heading(textStyle: .h5)
                    } label: {
                        Text("H5")
                            .help("Heading 5")
                    }
                    Button {
                        editorView.heading(textStyle: .h6)
                    } label: {
                        Text("H6")
                            .help("Heading 6")
                    }
                }
                .padding([.leading, .trailing], 10)
            }.padding([.leading], 40)
            //            HStack {
            //
            //                Group {
            //                    // bullet list
            //                    Button {
            //
            //                    } label: {
            //                        Image(systemName: "list.bullet")
            //                    }
            //
            //                    // numbers list
            //                    Button {
            //
            //                    } label: {
            //                        Image(systemName: "list.number")
            //                    }
            //
            //                    // check list
            //                    Button {
            //
            //                    } label: {
            //                        Image(systemName: "checklist")
            //                    }
            //                }
            //                .padding([.leading, .trailing], 5)
            //            }.padding([.leading], 40)
            HStack {
                Group {
                    // code
                    Button {
                        editorView.markInline()
                    } label: {
                        Image("inline_code")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .help("Inline Code")
                    }
                    // code
                    Button {
                        editorView.markCodeblock()
                    } label: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .help("Source Code")
                    }
                    // quote
                    Button {
                        editorView.markBlockQuote()
                    } label: {
                        Image(systemName: "text.quote")
                            .help("Quote Block")
                    }
                }
                .padding([.leading, .trailing], 10)
            }.padding([.leading], 40)
            //            HStack {
            //
            //                Group {
            //                    // link
            //                    Button {
            //                        // make selected range as bold
            //                        var change = currentTextStyleAction.2
            //                        change.toggle()
            //                        currentTextStyleAction = (.link, true, change)
            //                    } label: {
            //                        Image(systemName: "link")
            //                    }
            //
            //                    // image
            //                    Button {
            //                        // make selected range as bold
            //                        var change = currentTextStyleAction.2
            //                        change.toggle()
            //                        currentTextStyleAction = (.image, true, change)
            //                    } label: {
            //                        Image(systemName: "photo")
            //                    }
            //                }
            //                .padding([.leading, .trailing], 5)
            //            }.padding([.leading], 40)
            Spacer()
            HStack {
                Group {
                    // Clear
                    Button {
                        editorView.clearFormat()
                    } label: {
                        Text("Clear")
                            .help("Clear format")
                    }
                }
                .padding([.leading, .trailing], 5)
            }.padding([.leading], 40)
        }
        .buttonStyle(.plain)
    }
    
}
