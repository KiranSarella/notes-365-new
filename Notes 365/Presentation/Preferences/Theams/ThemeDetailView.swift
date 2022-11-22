//
//  ThemeDetailView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 02/07/22.
//

#if os(macOS)

import SwiftUI
//import SwiftUIWindow

struct ThemeDetailView: View {
    
    @Binding var globalTheme: MarkdownTheme
    var selectedThemeIndex: Int
    @State private var globalColor: NamedColor
    @State private var theme: MarkdownTheme
    
    @State private var isColorPickerWindowOpened = false
    
    init(theme: Binding<MarkdownTheme>, selectedThemeIndex: Int, globalColor: NamedColor) {
        _globalTheme = theme
        self.selectedThemeIndex = selectedThemeIndex
        _globalColor = State(initialValue: globalColor)
        _theme = State(initialValue: theme.wrappedValue)
    }
    
    @State var testColor: Color = .purple
    @State var testColor2: Color = .purple
    
    var body: some View {
        
        HStack {
            // settings
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // body
                    HStack(alignment: .top) {
                        
                        FontPicker("Font", selection: $theme.font)
                            .padding(.leading)
                        
                        Spacer()
//
//                        ColorPicker("test", selection: $testColor)
//                            .onChange(of: testColor) { newValue in
//                                print(NSColor(newValue).colorNameComponent)
//
//
////                                NSColor(named: NSColor(newValue).colorNameComponent)
//                            }
//
//                        ColorPicker("test2", selection: $testColor2)
                        
                        ColorPickerButton(selection: $globalColor)
                          .onChange(of: globalColor) { newValue in
                                theme.bodyColor = newValue
                                theme.headingColor = newValue
                                theme.styleColor = newValue
                                theme.codeColor = newValue
                                theme.blockQuoteColor = newValue
                                theme.listColor = newValue
//                                theme.linkColor = newValue
                            }
                            .padding(.trailing)
                        
                    }.padding([.leading, .trailing, .top])
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
                    .padding()
                    // heading
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .trailing) {
                            ColorPickerButton(selection: $theme.headingColor)
                                .padding(.trailing)
                        }
                    }.padding([.top, .leading, .trailing])
                    
                    // Heading section
                    HeadingSection(theme: $theme)
                        .padding([.horizontal])
                    
                    HStack {
                        Spacer()
                        Button {
                            
                            var newTheme: MarkdownTheme!
                            
                            if theme.themeName == "Black&White" {
                                newTheme = MarkdownTheme.generateBlackWhiteTheme()
                            } else if theme.themeName == "Color" {
                                newTheme = MarkdownTheme.generateColorTheme()
                            } else if theme.themeName == "Customized1" {
                                newTheme = MarkdownTheme.generateCustomized1Theme()
                            } else if theme.themeName == "Customized2" {
                                newTheme = MarkdownTheme.generateCustomized2Theme()
                            }
                            // use same id
                            newTheme.id = theme.id
                            theme = newTheme
                            
                        } label: {
                            Text("Reset")
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
            ThemePreviewView(theme: theme, selectedThemeIndex: selectedThemeIndex)
        }
        .focusable()
        .onDisappear {
            // reset state
            theme = globalTheme
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.set"))) { output in
            
            guard let selectedIndex = output.object as? Int else { return }
            
            if selectedThemeIndex == selectedIndex {
                // set if any changes
                globalTheme = theme // onChange will not work if no changes made to theme object
                // notify manually to set new selectedIndex
                NotificationCenter.default.post(name: Notification.Name("theme.save_object"), object: selectedIndex)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("colorpicker.window.appear"))) { output in
            
            guard let appearStatus = output.object as? Bool else { return }
            
            isColorPickerWindowOpened = appearStatus
        }
        
    }
    
}


struct ColorPickerButton: View {
    
    var colorPickerManager = ColorPickerWindowManager.shared
    
    @Binding var selection: NamedColor
    
    var body: some View {
     
        Button {
            
//            WindowGroup("colorpicker") {
//                ColorPickerWindow { newValue in
//                    selection = newValue
//                }
//            }
            
            colorPickerManager.openColorPickerWindow(caller: $selection)
            
//            openColorPickerWindow { newValue in
//                selection = newValue
//            }
            
        } label: {
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .border(Color.gray.opacity(0.8), width: 1)
                    .frame(width: 42, height: 23)
                
                Rectangle()
                    .foregroundColor(selection.color)
                    .border(Color.gray.opacity(0.8), width: 1)
                    .frame(width: 42 * 0.72, height: 23 * 0.58)
            }
            
        }
        .buttonStyle(.plain)
        
        
        
//        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("colorpicker.selection"))) { output in
//
//            guard let colorName = output.object as? NamedColor else { return }
//            print(colorName.rawValue)
//            selection = colorName
//        }
    }
    
    func openColorPickerWindow(completion: @escaping (NamedColor) -> ()) {
        
//        SwiftUIWindow.open { _ in
//
//            ColorPickerWindow { newValue in
//               completion(newValue)
//            }
//            .frame(width: 240, height: 360)
//        }
//        .clickable(true)
//        .mouseMovesWindow(true)
//        .alwaysOnTop(true)
//        .style([.titled, .closable])
    }
    
}


class ColorPickerWindowManager {
    
    static let shared = ColorPickerWindowManager()
    private init() {}
    
    var someWindow: NSWindow?
    
    func openColorPickerWindow(caller: Binding<NamedColor>) {
       
        if someWindow == nil {
            someWindow = NSWindow( contentRect: NSRect(x: 0, y: 0, width: 240, height: 360), styleMask: [.titled, .closable],  backing: .buffered, defer: false)
            someWindow?.isReleasedWhenClosed = false
        }

        guard let someWindow = someWindow else {
            return
        }

        someWindow.contentView = NSHostingView(rootView: ColorPickerWindow(didSelectionChanged: { newValue in
            caller.wrappedValue = newValue
        }))

        if someWindow.isVisible == false {

            someWindow.title = "Colors"
            someWindow.animationBehavior = .utilityWindow
            someWindow.collectionBehavior = .stationary
            someWindow.level = .floating
            someWindow.makeKeyAndOrderFront(nil)
            someWindow.center()
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
