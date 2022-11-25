//
//  ColorPickerView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 04/07/22.
//

import SwiftUI

#if os(macOS)

struct ColorPickerWindow: View {
    
    var didSelectionChanged: (NamedColor) -> ()
    
    func getCrayonsColorsList(name: String) -> NSColorList? {
        return NSColorList.availableColorLists.first { colorList in
            colorList.name == name
        }
        
//        NamedColorTwo(colorName: "Teal", listName: "Crayons")
    }
    
    @State private var selectedColor: NamedColor?
    
//    let staticColors:[NamedColor] =  [.black, .blue, .brown, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .white, .yellow]
//    let dynamicColors:[NamedColor] = [.primary, .secondary]
    
    let dynamicColors:[Color] = [.primary, .secondary]
    
    func prepareNamedColors(name: String) -> [NamedColor]? {
        guard let list = getCrayonsColorsList(name: name) else { return nil }
        var nameedClrs = [NamedColor]()
        for colorName in list.allKeys {
            nameedClrs.append(NamedColor(colorName: colorName, listName: name))
        }
        
        return nameedClrs
    }
    
    func prepareDynamicColors() -> [NamedColor] {
        return [
            NamedColor(colorName: "Primary", listName: "Dynamic"),
            NamedColor(colorName: "Secondary", listName: "Dynamic")
        ]
    }
    
    func prepareSystemColors() -> [NamedColor] {
        
        var list = [NamedColor]()
        
        for colorName in NamedSystemColor.allCases {
            list.append(NamedColor(colorName: colorName.rawValue, listName: "System"))
        }
        
        return list
    }
    
    var body: some View {
        List(selection: $selectedColor) {

            Section {
                ForEach(prepareDynamicColors(), id: \.self) { namedColor in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .inset(by: 1)
                                .fill(namedColor.color)
                            RoundedRectangle(cornerRadius: 4)
                                .inset(by: 1)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        }
                        .frame(width: 20, height: 20)
                        
                        Text(namedColor.colorName.capitalized)
                    }
                }
            } header: {
                
                HStack {
                    Text("Dynamic")
                    
                    Image(systemName: "info.circle.fill")
                        .frame(width: 14, height: 14)
                        .help("Color changes dynamically with system dark mode.")
                }
            }
            
            Section {
                ForEach(prepareSystemColors(), id: \.self) { namedColor in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .inset(by: 1)
                                .fill(namedColor.color)
                            RoundedRectangle(cornerRadius: 4)
                                .inset(by: 1)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        }
                        .frame(width: 20, height: 20)
                        
                        Text(namedColor.colorName.capitalized)
                    }
                }
            } header: {
                Text("System")
            }
            
            if let colorsList = prepareNamedColors(name: "Crayons") {
                Section {
                    ForEach(colorsList, id: \.self) { namedColor in
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .inset(by: 1)
                                    .fill(namedColor.color)
                                RoundedRectangle(cornerRadius: 4)
                                    .inset(by: 1)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            }
                            .frame(width: 20, height: 20)
                            
                            Text(namedColor.colorName.capitalized)
                        }
                    }
                } header: {
                    Text("Crayons")
                }
            }
            
            
        }
        .frame(width: 280, height: 320)
        .onChange(of: selectedColor) { newValue in
            
            guard let newValue = newValue else {
                return
            }
            
            didSelectionChanged(newValue)
            
//            selection = newValue
            
//            print(newValue)
//            NotificationCenter.default.post(name: Notification.Name("colorpicker.selection"), object: newValue)
        }
//        .onAppear {
//            NotificationCenter.default.post(name: Notification.Name("colorpicker.window.appear"), object: true)
//        }
//        .onDisappear {
//            NotificationCenter.default.post(name: Notification.Name("colorpicker.window.appear"), object: false)
//        }
    }
}

//struct ColorPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorPickerWindow()
//    }
//}


//struct MyColorPickerView: NSViewRepresentable {
//
//    typealias NSViewType = NSColorPicker
//
//    func makeNSView(context: Context) -> NSColorPicker {
//
//        let colorPicker = NSColorPicker()
//
//        let list = NSColorList(name: "dynamic colors")
//        list.insertColor(NSColor.labelColor, key: NSColor.Name("lable color"), at: 0)
//
//        colorPicker.attachColorList(list)
//
//        return colorPicker
//    }
//
//    func updateNSView(_ nsView: NSColorPicker, context: Context) {
//
//    }
//}

struct MyColorPickerView2: NSViewRepresentable {
    
    typealias NSViewType = NSTextView
    
    func makeNSView(context: Context) -> NSTextView {
        
        let colorPicker = NSTextView()
        
        
        let cpicker = NSColorPicker()
        
        
        let list = NSColorList(name: "dynamic colors")
        list.setColor(.labelColor, forKey: NSColor.Name("Primary"))
        
        
        cpicker.attachColorList(list)
        
        return colorPicker
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        
    }
}


#endif
