//
//  EditorTextView.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 05/05/22.
//

import Foundation

#if !os(iOS)

import AppKit

class EditorTextView: NSTextView {
    
    
    
    override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }
    
}

#else

import UIKit

class EditorTextView: UITextView {
    
    var smartLayoutManagerDelegate: SmartLayoutManagerDelegate!
    
    override func paste(_ sender: Any?) {
        
        
        
//        pasteAsPlainText(sender)
    }
    
}
#endif

