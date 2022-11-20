//
//  MarkdownLayoutManagerDelegate.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 15/04/22.
//

#if os(macOS)

import Foundation
import AppKit


class MarkdownLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
    
    var textView: NSTextView
    
    init(textView: NSTextView) {
        
        self.textView = textView
        
        super.init()
    }
    
    
}


#endif
