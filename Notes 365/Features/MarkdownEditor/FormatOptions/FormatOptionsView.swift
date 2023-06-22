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
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                Spacer()
                // bold, italic..
                HStack {
                    Group {
                        Button {
                            // make selected range as bold
                            editorView.markBold()
                            contentEditedDate = Date()
                        } label: {
                            Image(systemName: "bold")
                                .help("Bold")
                        }
                        Button {
                            // make selected range as italic
                            editorView.markItalic()
                            contentEditedDate = Date()
                        } label: {
                            Image(systemName: "italic")
                                .help("Italic")
                        }
                        Button {
                            editorView.markStrikethrough()
                            contentEditedDate = Date()
                        } label: {
                            Image(systemName: "strikethrough")
                                .help("Strikethrough")
                        }
                    }
                    .frame(width: 40, height: 44)
//                    .padding([.leading, .trailing], 2)
                }
                // H1,.. H6
                HStack {
                    Group {
                        Button {
                            editorView.heading(textStyle: .h1)
                            contentEditedDate = Date()
                        } label: {
                            Text("H1")
                                .help("Heading 1")
                        }
                        Button {
                            editorView.heading(textStyle: .h2)
                            contentEditedDate = Date()
                        } label: {
                            Text("H2")
                                .help("Heading 2")
                        }
                        Button {
                            editorView.heading(textStyle: .h3)
                            contentEditedDate = Date()
                        } label: {
                            Text("H3")
                                .help("Heading 3")
                        }
                        Button {
                            editorView.heading(textStyle: .h4)
                            contentEditedDate = Date()
                        } label: {
                            Text("H4")
                                .help("Heading 4")
                        }
                        Button {
                            editorView.heading(textStyle: .h5)
                            contentEditedDate = Date()
                        } label: {
                            Text("H5")
                                .help("Heading 5")
                        }
                        Button {
                            editorView.heading(textStyle: .h6)
                            contentEditedDate = Date()
                        } label: {
                            Text("H6")
                                .help("Heading 6")
                        }
                    }
                    .frame(width: 40, height: 44)
//                    .padding([.leading, .trailing], 10)
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
                            contentEditedDate = Date()
                        } label: {
                            Image("inline_code")
                                .resizable()
                                .frame(width: 26, height: 26)
                                .help("Inline Code")
                        }
                        // code
                        Button {
                            editorView.markCodeblock()
                            contentEditedDate = Date()
                        } label: {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .help("Source Code")
                        }
                        // quote
                        Button {
                            editorView.markBlockQuote()
                            contentEditedDate = Date()
                        } label: {
                            Image(systemName: "text.quote")
                                .help("Quote Block")
                        }
                    }
                    .frame(width: 40, height: 44)
//                    .padding([.leading, .trailing], 10)
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
                            contentEditedDate = Date()
                        } label: {
                            Text("Clear")
                                .help("Clear format")
                        }
                    }
                    .padding([.leading, .trailing], 5)
                }.padding([.leading], 40)
            }
            .frame(height: 40)
            
        }
        
        .buttonStyle(.plain)
    }
    
}

#Preview {
    FormattingOptionsView(editorView: Binding.constant(EditorView()) , contentEditedDate: Binding.constant(Date()))
}
