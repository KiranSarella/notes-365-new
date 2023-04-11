//
//  ColorPickerButton.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

#if os(macOS)

import SwiftUI


struct ColorPickerButton: View {
    
    var colorPickerManager = ColorPickerWindowManager.shared
    
    @Binding var selection: NamedColor
    
    var isGeneric: Bool
    
    var didValueChange: (()->())?
    
    init(selection: Binding<NamedColor>) {
        _selection = selection
        self.didValueChange = nil
        self.isGeneric = false
    }
    
    init(selection: Binding<NamedColor>, isGeneric: Bool = false, didValueChange: (()->())?) {
        _selection = selection
        self.didValueChange = didValueChange
        self.isGeneric = isGeneric
    }
    
    var body: some View {
        
        Button {
            
            //            WindowGroup("colorpicker") {
            //                ColorPickerWindow { newValue in
            //                    selection = newValue
            //                }
            //            }
            
            colorPickerManager.openColorPickerWindow(caller: $selection, didValueChange: didValueChange)
            
            //            openColorPickerWindow { newValue in
            //                selection = newValue
            //            }
            
        } label: {
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .border(Color.gray.opacity(0.8), width: 1)
                    .frame(width: 42, height: 23)
                
                if isGeneric {
                    Rectangle()
                        .fill(
                            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .orange, .white, .yellow]), center: .center)
                        )
                        .border(Color.gray.opacity(0.8), width: 1)
                        .frame(width: 42 * 0.72, height: 23 * 0.58)
                } else {
                    Rectangle()
                        .foregroundColor(selection.color)
                        .border(Color.gray.opacity(0.8), width: 1)
                        .frame(width: 42 * 0.72, height: 23 * 0.58)
                    
                }
                    
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


#endif
