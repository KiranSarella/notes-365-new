//
//  NewThemeView.swift
//  Notes 365
//
//  Created by kiran ipc on 24/07/23.
//

import SwiftUI

struct NewThemeView: View {
    
    @State var state = NewThemeState()
    
    var body: some View {
        VStack {
            ScrollView {
                // appearance
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
                                            .stroke(.pink, lineWidth: state.appearance == appearance ? 2 : 0)
                                        )
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                // background
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
                                            .stroke(.pink, lineWidth: state.background == background ? 2 : 0)
                                        )
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                // editor
//                HStack {
//                    Text("Editor")
//                    Spacer()
//                    
//                }
                
//                Picker("", selection: $state.editor) {
//                    ForEach(EditorThemeType.allCases) { editorType in
//                        Text(editorType.rawValue.capitalized)
//                    }
//                }
//                .padding()
                
                GroupBox("Editor") {
                    
                    Picker("", selection: $state.editor) {
                        ForEach(EditorThemeType.allCases) { editorType in
                            Text(editorType.rawValue.capitalized)
                        }
                    }
                    .padding(.vertical)

                    HStack {
                        Text("Font")
                        Spacer()
                        Button {
//                            state.showFontPicker = true
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
                    ColorPicker("Source Code", selection: $state.codeColor, supportsOpacity: false)
                    ColorPicker("Block Quote", selection: $state.quoteColor, supportsOpacity: false)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<10) {
                            Text("Item \($0)")
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .frame(width: 160, height: 80)
                                .background(.green)
                                .cornerRadius(10)
                        }
                    }
                }
                
            }
            .padding()
        }
        .pickerStyle(SegmentedPickerStyle())
    }
        
}

#Preview {
    NewThemeView()
}
