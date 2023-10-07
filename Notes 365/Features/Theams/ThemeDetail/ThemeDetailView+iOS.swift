//
//  ThemeDetailView+iOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 01/02/23.
//

import SwiftUI

// https://developer.apple.com/forums/thread/664922

struct ThemeDetailView_iOS: View {
    
    @Environment(\.dismiss) var dismiss
    
    var theme: MarkdownTheme
    
    @State var state = ThemeDetailState()
    
    var onThemeChange:((MarkdownTheme) -> ())
    
    @State var isFirstAppear = true
    
    var body: some View {
        
        VStack {
            
            List {
                // font name
//
//                NavigationLink {
//                    FontPicker { value in
//                        //                    print(value)
//                        let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
//                        fontName = value.familyName
//                        font = Font(newValue)
//                        //                            showFontPicker = false
//                    } onCancel: {
//                        //                            showFontPicker = false
//                    }
//                    .toolbar {
//                        Button {
//
//                        } label: {
//                            Text("Done")
//                        }
//                    }
//                } label: {
//
//                    HStack {
//                        Text("Font")
//                        Spacer()
//                        Text(fontName)
//                            .font(font)
//                    }
//
//
//                }
//                .navigationViewStyle(StackNavigationViewStyle())

                HStack {
                    Text("Font")
                    Spacer()
                    Button {
                        state.showFontPicker = true
                    } label: {
                        Text(state.fontName)
                            .font(state.font)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                // font size
                Stepper(value: $state.fontSize, in: state.range, step: state.step) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(state.fontSize)")
                    }
                }
                // color pickers
                ColorPicker("Body", selection: $state.bodyColor, supportsOpacity: false)
//                    .onChange(of: state.bodyColor) { newValue in
//                        print(newValue.components)
//                    }
                
                ColorPicker("Heading", selection: $state.headingColor, supportsOpacity: false)
                ColorPicker("Bold, Italic, Strikthrough", selection: $state.boldColor, supportsOpacity: false)
                ColorPicker("List", selection: $state.listColor, supportsOpacity: false)
                ColorPicker("Highlight", selection: $state.highlightColor, supportsOpacity: false)
                ColorPicker("Source Code", selection: $state.codeColor, supportsOpacity: false)
                ColorPicker("Block Quote", selection: $state.quoteColor, supportsOpacity: false)
            }
            .navigationTitle(theme.themeName)
            .sheet(isPresented: $state.showFontPicker) {
                NavigationStack {
                    FontPicker { value in
                        //                    print(value)
                        let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
                        state.fontName = value.familyName
                        state.font = Font(newValue)
                        state.showFontPicker = false
                    } onCancel: {
                        state.showFontPicker = false
                    }
                    .toolbar {
                        Button {
                            state.showFontPicker = false
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    Button {
                        // save theme
                        state.resetTheme()
                    } label: {
                        Text("Reset")
                    }
                    
                    Button {
                        // save theme
                        state.updateChanges()
                        onThemeChange(state.theme)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    
                }
            }
        }
        .onAppear {
            if isFirstAppear {
                state.theme = theme
                state.populateFields()
                
                isFirstAppear = false
            }
            
        }
    }
}

//struct ThemeDetailView_iOS_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeDetailView_iOS()
//    }
//}
