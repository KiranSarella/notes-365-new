//
//  NewThemeView.swift
//  Notes 365
//
//  Created by kiran ipc on 24/07/23.
//

import SwiftUI

struct NewThemeView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var state = NewThemeState()
    
    var body: some View {
        VStack {
            ScrollView {
                // appearance
//                AppearanceOptionsView(state: state)
                // background
//                BackgroundOptionsView(state: state)
                // editor
                EditorOptionsView(state: state)
                // theme cards
                ThemeCardView()
            }
            .padding()
        }
        .navigationTitle("Themes")
        .pickerStyle(SegmentedPickerStyle())
    }
        
}

fileprivate struct AppearanceOptionsView: View {
    
    @Bindable var state: NewThemeState
    
    var body: some View {
        
        GroupBox("Appearance")  {
            HStack {
                Spacer()
                HStack {
                    ForEach(Appearance.allCases) { appearance in
                        Button(action: {
                            state.appearance = appearance
                        }, label: {
                            Text(appearance.title)
                                .padding()
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 6,
                                        style: .continuous
                                    )
                                    .stroke(Color.accentColor, lineWidth: state.appearance == appearance ? 1 : 0)
                                )
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
}


fileprivate struct BackgroundOptionsView: View {
    
    @Bindable var state: NewThemeState
    
    var body: some View {
        
        GroupBox("Background")  {
            HStack {
                Spacer()
                HStack {
                    ForEach(ThemeBackground.allCases) { background in
                        Button(action: {
                            state.background = background
                        }, label: {
                            Text(background.title)
                                .padding()
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 6,
                                        style: .continuous
                                    )
                                    .stroke(Color.accentColor, lineWidth: state.background == background ? 1 : 0)
                                )
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                }
            }
        }
    }
    
}

fileprivate struct EditorOptionsView: View {
    
    @Bindable var state: NewThemeState
    
    let step = 2
    let range = 8...64
    
    var body: some View {
        // editor
        GroupBox("Editor") {
            VStack {
                Picker("", selection: $state.editorAppearance) {
                    ForEach(EditorAppearanceType.allCases) { editorType in
                        Text(editorType.rawValue.capitalized)
                    }
                }
                .padding(.vertical)
                .onChange(of: state.editorAppearance) { old, new in
                    state.didChange(editorAppearance: new)
                }
                
                HStack {
                    Text("Font")
                    Spacer()
                    Button {
//                            state.showFontPicker = true
                    } label: {
                        Text(state.activeTheme.fontName)
//                            .font(state.activeTheme.font2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                // font size
                Stepper(value: $state.activeTheme.fontSize, in: range, step: step) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(state.activeTheme.fontSize)")
                    }
                }
                // color pickers
                ColorPicker("Body", selection: $state.activeTheme.bodyColor.color, supportsOpacity: false)
                ColorPicker("Heading", selection: $state.activeTheme.headingColor.color, supportsOpacity: false)
                ColorPicker("Bold, Italic, Strikthrough", selection: $state.activeTheme.styleColor.color, supportsOpacity: false)
                ColorPicker("List", selection: $state.activeTheme.listColor.color, supportsOpacity: false)
                ColorPicker("Source Code", selection: $state.activeTheme.codeColor.color, supportsOpacity: false)
                ColorPicker("Block Quote", selection: $state.activeTheme.blockQuoteColor.color, supportsOpacity: false)
            }
//                    .padding()
            
        }

    }
    
}


#Preview {
    NewThemeView()
}
