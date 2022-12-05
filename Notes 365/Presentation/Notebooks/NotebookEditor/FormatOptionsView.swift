//
//  FormatOptionsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI


struct FormattingOptionsView: View {
    @Binding var editorView: EditorView
    @Binding var currentTextStyleAction: (TextStyleKey?, Any, Bool)
    var body: some View {
        HStack {
            Spacer()
            // bold, italic..
            HStack {
                Group {
                    Button {
                        // make selected range as bold
//                        var change = currentTextStyleAction.2
//                        change.toggle()
//                        currentTextStyleAction = (.bold, true, change)
                        
                        editorView.markBold {
                            
                        }
                        
                    } label: {
                        Image(systemName: "bold")
                            .help("Bold")
                    }
                    Button {
                        // make selected range as italic
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.italic, true, change)
                    } label: {
                        Image(systemName: "italic")
                            .help("Italic")
                    }
                    Button {
                        // make selected range as italic
                        var change = currentTextStyleAction.2
                        change.toggle()
                        
                        currentTextStyleAction = (.strikethrough, true, change)
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
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h1, true, change)
                    } label: {
                        Text("H1")
                            .help("Heading 1")
                    }
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h2, true, change)
                    } label: {
                        Text("H2")
                            .help("Heading 2")
                    }
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h3, true, change)
                    } label: {
                        Text("H3")
                            .help("Heading 3")
                    }
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h4, true, change)
                    } label: {
                        Text("H4")
                            .help("Heading 4")
                    }
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h5, true, change)
                    } label: {
                        Text("H5")
                            .help("Heading 5")
                    }
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.h6, true, change)
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
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.inline, true, change)
                    } label: {
                        Image("inline_code")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .help("Inline Code")
                    }
                    // code
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.codeBlock, true, change)
                    } label: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .help("Source Code")
                    }
                    // quote
                    Button {
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.blockQuote, true, change)
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
                        // make selected range as bold
                        var change = currentTextStyleAction.2
                        change.toggle()
                        currentTextStyleAction = (.clear, true, change)
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
