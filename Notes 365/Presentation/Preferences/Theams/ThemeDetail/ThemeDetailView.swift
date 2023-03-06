//
//  ThemeDetailView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 02/07/22.
//

#if os(macOS)

import SwiftUI
//import SwiftUIWindow


//struct NavContainerView: View {
//    
//    @Binding var baseTheme: MarkdownTheme?
//    
//    @State private var showContent = false
//    
//    var body: some View {
//        VStack {
//            
//            if let baseThemee = $baseTheme {
//                ThemeDetailView(theme: Binding(baseThemee)!)
//            }
//            
//        }.onChange(of: baseTheme) { newValue in
//            if newValue == nil {
//                showContent = false
//            } else {
//                
//            }
//        }
//    }
//}

struct ThemeDetailView: View {
    
    var didThemeChange: ((MarkdownTheme)->())
    
    @Binding var baseTheme: MarkdownTheme
    @State private var theme: MarkdownTheme
    
    @State private var font: NSFont
    @State private var globalColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    @State private var tintColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    
    @State private var isColorPickerWindowOpened = false
    
    init(theme inputTheme: Binding<MarkdownTheme>, didThemeChange: @escaping ((MarkdownTheme)->())) {
        _baseTheme = inputTheme
        _theme = State(initialValue: inputTheme.wrappedValue)
        self.didThemeChange = didThemeChange
        _font = State(initialValue: inputTheme.wrappedValue.font)
    }
    
    var body: some View {
        HStack {
            // settings
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // body
                    HStack(alignment: .top) {
                        // font name
                        FontPicker("Font", selection: $font) {
                            theme.fontName = font.fontName
                            theme.fontSize = Float(font.fontDescriptor.pointSize)
                        }
                        .padding(.leading)
                        Spacer()
                        // global color
                        ColorPickerButton(selection: $globalColor, isGeneric: true) {
                            theme.headingColor = globalColor
                            tintColor = globalColor
                            
                            theme.bodyColor = globalColor
                            theme.styleColor = globalColor
                            theme.codeColor = globalColor
                            theme.blockQuoteColor = globalColor
                            theme.listColor = globalColor
                        }
                        .padding(.trailing)
                        
                    }.padding([.leading, .trailing, .top])
                    // tint color
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .trailing) {
                            ColorPickerButton(selection: $tintColor, isGeneric: true) {
                                theme.bodyColor = tintColor
                                theme.styleColor = tintColor
                                theme.codeColor = tintColor
                                theme.blockQuoteColor = tintColor
                                theme.listColor = tintColor
                            }
                            .padding(.trailing)
                        }
                    }.padding([.top, .leading, .trailing])
                    // bold, italic
                    VStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.1)
                            VStack {
                                // body
                                HStack {
                                    Text("Body")
                                    Spacer()
                                    ColorPickerButton(selection: $theme.bodyColor)
                                }
                                // bold
                                HStack {
                                    HStack {
                                        Text("Bold")
                                            .bold()
                                        Text("Italic")
                                            .italic()
                                        Text("Strikethrough")
                                            .strikethrough()
                                    }
                                    Spacer()
                                    ColorPickerButton(selection: $theme.styleColor)
                                }
                                // code block
                                HStack {
                                    Text("Code")
                                        .font(Font.monospaced(Font.system(size: 12))())
                                    Spacer()
                                    ColorPickerButton(selection: $theme.codeColor)
                                }
                                // block quote
                                HStack(alignment: .top) {
                                    Text("Block Quote")
                                        .fontWeight(.medium)
                                    Spacer()
                                    ColorPickerButton(selection: $theme.blockQuoteColor)
                                }
                                // List
                                HStack(alignment: .top) {
                                    Text("List")
                                        .fontWeight(.medium)
                                    Spacer()
                                    ColorPickerButton(selection: $theme.listColor)
                                }
//                                // Link
//                                HStack(alignment: .top) {
//                                    Text("Link")
//                                        .underline()
//                                    Spacer()
//                                    ColorPickerButton(selection: $theme.linkColor)
//                                }
                            }.padding()
                        }
                    }
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                            .brightness(0.38)
                    )
                    .padding([.horizontal])
                    // heading
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .trailing) {
                            ColorPickerButton(selection: $theme.headingColor, isGeneric: true) {
                                
                            }
                            .padding(.trailing)
                        }
                    }.padding([.top, .leading, .trailing])
                    
                    // Heading section
                    HeadingSection(theme: $theme)
                        .padding([.horizontal])
                    
                    HStack {
                        Button {
                            
                            var newTheme: MarkdownTheme!
                            
                            if theme.themeName == "Black&White" {
                                newTheme = ThemeBusiness.generateBasicLightTheme()
                            } else if theme.themeName == "Color" {
                                newTheme = ThemeBusiness.generateBasicDarkTheme()
                            } else if theme.themeName == "Customized1" {
                                newTheme = ThemeBusiness.generateCustomizedLightTheme()
                            } else if theme.themeName == "Customized2" {
                                newTheme = ThemeBusiness.generateCustomizedDarkTheme()
                            }
                            // use same id
                            newTheme.id = theme.id
                            theme = newTheme
                            
                        } label: {
                            Text("Reset")
                        }
                        .padding()
                        Spacer()
                        Button {
                            didThemeChange(theme)
                        } label: {
                            Text("Save Changes")
                        }
//                        .padding()
                        Button {
                            theme = baseTheme
                        } label: {
                            Text("Discard")
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
                .onAppear {
                    
                    globalColor = theme.bodyColor
                }
                
            }
            .frame(width: 420)
            
            // preview
            ThemePreviewView(theme: theme)
        }
        .onChange(of: baseTheme, perform: { newValue in
            self.theme = newValue
            globalColor = baseTheme.bodyColor
            font = newValue.font
        })
        .onAppear {
            globalColor = baseTheme.bodyColor
            font = baseTheme.font
        }
        .focusable()
        .onDisappear {
            // reset state
            theme = baseTheme
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("colorpicker.window.appear"))) { output in
            
            guard let appearStatus = output.object as? Bool else { return }
            
            isColorPickerWindowOpened = appearStatus
        }
        
    }
    
}




struct HeadingSection: View {
    
    @Binding var theme: MarkdownTheme
    
    func getHeadingBinding(forHeading headingType: MarkdownHeading) -> Binding<NamedColor> {
        switch headingType {
        case .h1:
            return $theme.h1Color
        case .h2:
            return $theme.h2Color
        case .h3:
            return $theme.h3Color
        case .h4:
            return $theme.h4Color
        case .h5:
            return $theme.h5Color
        case .h6:
            return $theme.h6Color
        }
    }
    
    var body: some View {
        
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.1)
                HStack {
                    VStack {
                        ForEach(MarkdownHeading.allCases, id: \.self) { heading in
                            HeadingRow(heading: heading, parentColor: $theme.headingColor, color: getHeadingBinding(forHeading: heading))
                        }
                    }
                }
                .padding()
            }
        }
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 1)
                .brightness(0.38)
        )
        
    }
}

struct HeadingRow: View {
    
    var heading: MarkdownHeading
    
    @Binding var parentColor: NamedColor
    @Binding var color: NamedColor
    
    var body: some View {
        HStack {
            Text(heading.title)
                .font(Font.system(size: heading.fontSize))
                .fontWeight(.bold)
                .onChange(of: parentColor) { newValue in
                    color = newValue
                }
            Spacer()
            ColorPickerButton(selection: $color)
        }
    }
}



struct OptionRow: View {
    
    var title: String
    var fontName: String
    
    @Binding var parentColor: Color
    
    @State private var color: Color = .black
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.custom(fontName, size: 12))
                .fontWeight(.bold)
                .foregroundColor(color)
                .onAppear(perform: {
                    color = parentColor
                })
                .onChange(of: parentColor) { newValue in
                    color = newValue
                }
            
            Spacer()
            
            ColorPicker("", selection: $color, supportsOpacity: false)
        }
    }
}

#endif
