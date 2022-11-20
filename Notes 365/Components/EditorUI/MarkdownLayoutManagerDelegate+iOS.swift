//
//  MarkdownLayoutManagerDelegate.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 15/04/22.
//

#if os(iOS)

import Foundation
import UIKit


class MarkdownLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
    
    var textView: UITextView
    
    init(textView: UITextView) {
        
        self.textView = textView
        
        super.init()
    }
    
    
}

#endif
