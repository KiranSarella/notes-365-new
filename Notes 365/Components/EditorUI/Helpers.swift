//
//  Helpers.swift
//  Notes 365
//
//  Created by Kiran Sarella on 03/07/22.
//

#if os(macOS)

import Foundation
import Cocoa

@IBDesignable
@objc(BCLDisablableScrollView)
public class DisablableScrollView: NSScrollView {
    @IBInspectable
    @objc(enabled)
    public var isEnabled: Bool = false
    
    public override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}

#endif
