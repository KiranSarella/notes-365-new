//
//  MyLayoutManager.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 13/04/22.
//

#if os(iOS)

import Foundation
import UIKit


class SmartLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
    
    var textView: UITextView
    
    init(textView: UITextView) {
        
        self.textView = textView
        
        super.init()
    }
    
    
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        
        
        if let info = textView.textStorage.attribute(.markdownInfo, at: charIndexes.pointee, effectiveRange: nil) as? [String: Any] {
//            print(info)
            if info["type"] as! String == "codeblock" {
                return 0
            }
        }
        
        
        // Make mutableProperties an optional to allow checking if it gets allocated
        var mutableProperties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = nil
        
        
        
        // Check the attributes value only at charIndexes.pointee, where this glyphRange begins
        if let attribute = textView.textStorage.attribute(.markdown, at: charIndexes.pointee, effectiveRange: nil) as? Int, attribute == 0 {
            
            // Allocate mutableProperties
            mutableProperties = .allocate(capacity: glyphRange.length)
            // Initialize each element of mutableProperties
            for index in 0..<glyphRange.length {
                mutableProperties?[index] = .null
            }
        }
        
        // Update only if mutableProperties was allocated
        if let mutableProperties = mutableProperties {
            
            layoutManager.setGlyphs(glyphs, properties: mutableProperties, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            
            // Clean up this UnsafeMutablePointer
            mutableProperties.deinitialize(count: glyphRange.length)
            mutableProperties.deallocate()
            
            return glyphRange.length
            
        } else { return 0 }
    }
    
}



class SmartLayoutManagerDelegateTwo: NSObject, NSLayoutManagerDelegate {
    
    var textStorage: NSTextStorage
    
    init(textStorage: NSTextStorage) {
        
        self.textStorage = textStorage
        
        super.init()
    }
    
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        
        
        // Make mutableProperties an optional to allow checking if it gets allocated
        var mutableProperties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = nil
        
        
        
        // Check the attributes value only at charIndexes.pointee, where this glyphRange begins
        if let attribute = textStorage.attribute(.markdown, at: charIndexes.pointee, effectiveRange: nil) as? Int, attribute == 0 {
            
            // Allocate mutableProperties
            mutableProperties = .allocate(capacity: glyphRange.length)
            // Initialize each element of mutableProperties
            for index in 0..<glyphRange.length {
                mutableProperties?[index] = .null
            }
        }
        
        // Update only if mutableProperties was allocated
        if let mutableProperties = mutableProperties {
            
            layoutManager.setGlyphs(glyphs, properties: mutableProperties, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            
            // Clean up this UnsafeMutablePointer
            mutableProperties.deinitialize(count: glyphRange.length)
            mutableProperties.deallocate()
            
            return glyphRange.length
            
        } else { return 0 }
    }
    
}

#endif
