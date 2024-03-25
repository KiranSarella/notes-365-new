//
//  ThemeDetailView+iOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 01/02/23.
//

import SwiftUI

enum FontPickerInput: String {
    case body
    case heading
    case blockQuote
    case code
}

struct ThemeOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var theme: MarkdownTheme
    @State var isFirstAppear = true
    
    @State var font: Font = Font.system(Font.TextStyle.body)
    @State var fontSize: Int = 16
    @Binding var onReset: Bool
    
    @State var selectedFontPicker: FontPickerInput?
    @State var showFontPicker = false
    
    @State var headingFont: Font = Font.system(Font.TextStyle.body)
    @State var blockQuoteFont: Font = Font.system(Font.TextStyle.body)
    @State var codeFontName: Font = Font.system(Font.TextStyle.body)
    
    @State var codeFont: Font = Font.system(Font.TextStyle.body)
    
    let step: Int = 2
    let range = 8...64
    
    let defaultThemes: [Theme]
    @Binding var selectedDefaultTheme: Theme?
    

    
    var body: some View {
        VStack {
            List {
                

                // fonts
                Section {
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
                        Text("Body Font")
                        Spacer()
                        Button {
                            selectedFontPicker = .body
                            showFontPicker = true
                        } label: {
                            Text(theme.fontName)
                                .font(font)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack {
                        Text("Heading Font")
                        Spacer()
                        Button {
                            selectedFontPicker = .heading
                            showFontPicker = true
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
                            selectedFontPicker = .blockQuote
                            showFontPicker = true
                        } label: {
                            Text(theme.blockQuoteFontName)
                                .font(blockQuoteFont)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack {
                        Text("Code Font")
                        Spacer()
                        Button {
                            selectedFontPicker = .code
                            showFontPicker = true
                        } label: {
                            Text(theme.codeFontName)
                                .font(codeFontName)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    
                }
                
                // colors
                Section {
                    ColorPicker("Background", selection: $theme.canvasColor, supportsOpacity: true)
                    ColorPicker("Body", selection: $theme.bodyColor, supportsOpacity: false)
                    ColorPicker("Headings", selection: $theme.headingColor, supportsOpacity: false)
                    ColorPicker("Style", selection: $theme.styleColor, supportsOpacity: false)
                    ColorPicker("Block Quote", selection: $theme.blockQuoteColor, supportsOpacity: false)
                    ColorPicker("Code", selection: $theme.codeColor, supportsOpacity: false)
                }
             
                // theme blocks
                Section {
                    
                } header: {
                    VStack {
                        
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
                                    .padding(10)
                                }
                            }
                        }
                        .padding(.horizontal, -10)
                    }
                } footer: {
                    
                   
                    
                }
                

            }
            .sheet(isPresented: $showFontPicker) {
                NavigationStack {
                    FontPicker { value in
                        let newValue = UIFont(descriptor: value.fontDescriptor, size: 16)
                        
                        if let selectedFontPicker = selectedFontPicker {
                            switch selectedFontPicker {
                            case .body:
                                theme.fontName = value.familyName
                                font = Font(newValue)
                            case .heading:
                                theme.headingFontName = value.familyName
                                headingFont = Font(newValue)
                            case .blockQuote:
                                theme.blockQuoteFontName = value.familyName
                                blockQuoteFont = Font(newValue)
                            case .code:
                                theme.codeFontName = value.familyName
                                codeFontName = Font(newValue)
                            }
                        }
                        
                        
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
        if let uifont = UIFont(name: theme.codeFontName, size: 16) {
            codeFontName = Font(uifont)
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
    static var radius: CGFloat = 4
    static var x: CGFloat = 4
    static var y: CGFloat = 4
}

struct PressedNeumorphicState: NeumorphicShadowState {
    static var radius: CGFloat = 2
    static var x: CGFloat = 1
    static var y: CGFloat = 1
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
