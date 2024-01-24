//
//  ThemeDetailView+iOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 01/02/23.
//

import SwiftUI

struct ThemeOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var theme: MarkdownTheme
    @State var isFirstAppear = true
    @State var showFontPicker = false
    @State var font: Font = Font.system(Font.TextStyle.body)
    @State var fontSize: Int = 16
    @Binding var onReset: Bool
    
    
    @State var enableOtherFonts = true
    @State var showHeadingFontPicker = false
    @State var showBlockQuoteFontPicker = false
    @State var headingFont: Font = Font.system(Font.TextStyle.body)
    @State var blockQuoteFont: Font = Font.system(Font.TextStyle.body)
    
    let step: Int = 2
    let range = 8...64
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Font")
                    Spacer()
                    Button {
                        showFontPicker = true
                    } label: {
                        Text(theme.fontName)
                            .font(font)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                // font size
                Stepper(value: $fontSize, in: range, step: step) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(fontSize)")
                    }
                }
                .onChange(of: fontSize) { oldValue, newValue in
                    theme.fontSize = Float(newValue)
                }
                ColorPicker("Background", selection: $theme.canvasColor, supportsOpacity: true)
                ColorPicker("Body", selection: $theme.bodyColor, supportsOpacity: false)
                ColorPicker("Heading", selection: $theme.headingColor, supportsOpacity: false)
                ColorPicker("Bold, Italic, Strikthrough", selection: $theme.styleColor, supportsOpacity: false)
                ColorPicker("List", selection: $theme.listColor, supportsOpacity: false)
                ColorPicker("Highlight", selection: $theme.highlightColor, supportsOpacity: true)
                ColorPicker("Source Code", selection: $theme.codeColor, supportsOpacity: false)
                ColorPicker("Block Quote", selection: $theme.blockQuoteColor, supportsOpacity: false)
                
                Section {
                    HStack {
                        Text("Heading Font")
                        Spacer()
                        Button {
                            showHeadingFontPicker = true
                        } label: {
                            Text(theme.headingFontName)
                                .font(headingFont)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    HStack {
                        Text("Block Quote Font")
                        Spacer()
                        Button {
                            showBlockQuoteFontPicker = true
                        } label: {
                            Text(theme.blockQuoteFontName)
                                .font(blockQuoteFont)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    Toggle("More", isOn: $enableOtherFonts)
                }

                
            }
            .sheet(isPresented: $showFontPicker) {
                NavigationStack {
                    FontPicker { value in
                        let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
                        theme.fontName = value.familyName
                        font = Font(newValue)
#if targetEnvironment(macCatalyst)
                
#else
                        showFontPicker = false
#endif
                    } onCancel: {
#if targetEnvironment(macCatalyst)
                
#else
                        showFontPicker = false
#endif
                    }
                    .toolbar {
                        Button {
#if targetEnvironment(macCatalyst)
                
#else
                            showFontPicker = false
#endif
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showHeadingFontPicker) {
            NavigationStack {
                FontPicker { value in
                    let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
                    theme.headingFontName = value.familyName
                    headingFont = Font(newValue)
#if targetEnvironment(macCatalyst)
            
#else
                    showHeadingFontPicker = false
#endif
                } onCancel: {
#if targetEnvironment(macCatalyst)
            
#else
                    showHeadingFontPicker = false
#endif
                }
                .toolbar {
                    Button {
#if targetEnvironment(macCatalyst)
            
#else
                        showHeadingFontPicker = false
#endif
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .sheet(isPresented: $showBlockQuoteFontPicker) {
            NavigationStack {
                FontPicker { value in
                    let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
                    theme.blockQuoteFontName = value.familyName
                    blockQuoteFont = Font(newValue)
#if targetEnvironment(macCatalyst)
            
#else
                    showBlockQuoteFontPicker = false
#endif
                } onCancel: {
#if targetEnvironment(macCatalyst)
            
#else
                    showBlockQuoteFontPicker = false
#endif
                }
                .toolbar {
                    Button {
#if targetEnvironment(macCatalyst)
            
#else
                        showBlockQuoteFontPicker = false
#endif
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .onAppear {
            if isFirstAppear {
                fontSize = Int(theme.fontSize)
                isFirstAppear = false
                if let uifont = UIFont(name: theme.fontName, size: 16) {
                    font = Font(uifont)
                }
                if let uifont = UIFont(name: theme.headingFontName, size: 16) {
                    headingFont = Font(uifont)
                }
                if let uifont = UIFont(name: theme.blockQuoteFontName, size: 16) {
                    blockQuoteFont = Font(uifont)
                }
            }
        }
        .onChange(of: onReset) { oldValue, newValue in
            fontSize = Int(theme.fontSize)
            if let uifont = UIFont(name: theme.fontName, size: 16) {
                font = Font(uifont)
            }
            if let uifont = UIFont(name: theme.headingFontName, size: 16) {
                headingFont = Font(uifont)
            }
            if let uifont = UIFont(name: theme.blockQuoteFontName, size: 16) {
                blockQuoteFont = Font(uifont)
            }
        }
    }
}

//struct ThemeDetailView_iOS_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeDetailView_iOS()
//    }
//}
