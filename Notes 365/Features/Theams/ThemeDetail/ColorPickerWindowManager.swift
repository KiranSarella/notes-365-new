//
//  ColorPickerWindowManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

#if os(macOS)

import SwiftUI
import AppKit

class ColorPickerWindowManager {
    
    static let shared = ColorPickerWindowManager()
    private init() {}
    
    var someWindow: NSWindow?
    
    func openColorPickerWindow(caller: Binding<NamedColor>, didValueChange: (()->())? = nil) {
        
        if someWindow == nil {
            someWindow = NSWindow( contentRect: NSRect(x: 0, y: 0, width: 240, height: 360), styleMask: [.titled, .closable],  backing: .buffered, defer: false)
            someWindow?.isReleasedWhenClosed = false
        }
        
        guard let someWindow = someWindow else {
            return
        }
        
        someWindow.contentView = NSHostingView(rootView: ColorPickerWindow(didSelectionChanged: { newValue in
            caller.wrappedValue = newValue
            didValueChange?()
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

#endif
