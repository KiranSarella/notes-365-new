//
//  EditorTextView.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 05/05/22.
//

import Foundation

#if os(macOS)

import AppKit

class EditorTextView: NSTextView {
    
    override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }
}
#endif

