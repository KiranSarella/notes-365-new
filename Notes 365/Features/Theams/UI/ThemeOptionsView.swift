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
       
    @State var showHeadingFontPicker = false
    @State var showBlockQuoteFontPicker = false
    @State var headingFont: Font = Font.system(Font.TextStyle.body)
    @State var blockQuoteFont: Font = Font.system(Font.TextStyle.body)
    
    let step: Int = 2
    let range = 8...64
    
    let defaultThemes: [Theme]
    @Binding var selectedDefaultTheme: Theme?
    

    
    var body: some View {
        VStack {
            List {
                
                Section {
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
                    HStack {
                        ColorPicker("Background", selection: $theme.canvasColor, supportsOpacity: true)
                            .disabled(!theme.enableBackground)
                        
                        Toggle("Background", isOn: $theme.enableBackground)
                            .labelsHidden()
                    }
                }
                
                Section {
                    ColorPicker("Body", selection: $theme.bodyColor, supportsOpacity: false)
                    ColorPicker("Bold, Italic, Strikthrough", selection: $theme.styleColor, supportsOpacity: false)
                    ColorPicker("Highlight", selection: $theme.highlightColor, supportsOpacity: true)
                    ColorPicker("List", selection: $theme.listColor, supportsOpacity: false)
                    ColorPicker("Source Code", selection: $theme.codeColor, supportsOpacity: false)
                }
             
                Section {
                    ColorPicker("Heading", selection: $theme.headingColor, supportsOpacity: false)
                    HStack {
                        Text("Heading Font")
                        Spacer()
                        HStack {
                            Button {
                                showHeadingFontPicker = true
                            } label: {
                                Text(theme.headingFontName)
                                    .font(headingFont)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!theme.enableHeadingFont)
                            
                            Toggle("Heading Font", isOn: $theme.enableHeadingFont)
                                .labelsHidden()
                        }
                    }
                }
                
                Section {
                    ColorPicker("Block Quote", selection: $theme.blockQuoteColor, supportsOpacity: false)
                    HStack {
                        Text("Block Quote Font")
                        Spacer()
                        HStack {
                            Button {
                                showBlockQuoteFontPicker = true
                            } label: {
                                Text(theme.blockQuoteFontName)
                                    .font(blockQuoteFont)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!theme.enableBlockQuoteFont)
                            
                            Toggle("", isOn: $theme.enableBlockQuoteFont)
                                .labelsHidden()
                        }
                    }
                } 
                
                Section {
                    
                } header: {
                    
                } footer: {
                    
                    VStack {
                        
                        HStack {
                            Text("Default Themes")
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(defaultThemes) { theme in
                                    Button(action: {
                                        selectedDefaultTheme = theme
                                    }, label: {
                                        VStack {
                                            HStack {
                                                Image(systemName: "text.word.spacing")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .padding(.horizontal, 8)
                                                    .foregroundStyle(theme.bodyColor)
                                                Spacer()
                                                Image(systemName: "paintbrush.pointed.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(theme.headingColor)
                                            }
                                            .frame(height: 40)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                                            
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(theme.styleColor)
                                                    .frame(height: 25)
                                                Circle()
                                                    .fill(theme.blockQuoteColor)
                                                    .frame(height: 20)
                                                Circle()
                                                    .fill(theme.codeColor)
                                                    .frame(height: 15)
                                                Circle()
                                                    .fill(theme.listColor)
                                                    .frame(height: 10)
                                            }
                                        }
                                        .frame(width: 100, height: 60)
                                    })
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: theme.getBackgroundColor))
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal, -20)
                    }
                    
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
                updateFields()
                isFirstAppear = false
            }
        }
        .onChange(of: onReset) { oldValue, newValue in
            updateFields()
        }
    }
    
    func updateFields() {
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

//struct ThemeDetailView_iOS_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeDetailView_iOS()
//    }
//}


struct ThemeBoxStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(.gray, lineWidth: 1)
            )
    }
}

extension ButtonStyle where Self == ThemeBoxStyle {
    static var themeBox: Self {
        return .init()
    }
}

// ref: https://sarunw.com/posts/swiftui-buttonstyle/
struct NeumorphicButtonStyle: ButtonStyle {
    var bgColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .shadow(color: .white, 
                                radius: configuration.radius,
                                x: -configuration.x,
                                y: -configuration.y)
                        .shadow(color: .black,
                                radius: configuration.radius,
                                x: configuration.x,
                                y: configuration.y)
                        .blendMode(.overlay)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(bgColor)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.primary)
            .animation(.spring, value: configuration.isPressed)
    }
}

// want to try State pattern, end up like this.
protocol NeumorphicShadowState {
    static var radius: CGFloat { get }
    static var x: CGFloat { get }
    static var y: CGFloat { get }
}

struct DefaultNeumorphicState: NeumorphicShadowState {
    static var radius: CGFloat = 8
    static var x: CGFloat = 8
    static var y: CGFloat = 8
}

struct PressedNeumorphicState: NeumorphicShadowState {
    static var radius: CGFloat = 4
    static var x: CGFloat = 3
    static var y: CGFloat = 3
}

extension  ButtonStyleConfiguration {
    
    private var shadowState: NeumorphicShadowState.Type {
        isPressed ? PressedNeumorphicState.self : DefaultNeumorphicState.self
    }
    
    var x: CGFloat {
        shadowState.x
    }
    
    var y: CGFloat {
        shadowState.y
    }
    
    var radius: CGFloat {
        shadowState.radius
    }
    
}
