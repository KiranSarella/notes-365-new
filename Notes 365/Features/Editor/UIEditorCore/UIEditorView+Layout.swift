//
//  EditorView+Layout.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//


import UIKit
import Combine


extension UIEditorView: NSLayoutManagerDelegate {
    
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        
//        logger.debug("\(#function)")
//
//        print(glyphRange)
//
//        print(textView.selectedRange)
//
//        let lineRange = (textStorage.string as NSString).lineRange(for: textView.selectedRange)
//        print("lineRange", lineRange)
////
//
//        print("NSIntersectsRect", NSIntersectionRange(glyphRange, lineRange))
//        print(glyphRange.intersection(textView.selectedRange))
//        print(textView.selectedRange.intersection(glyphRange))
//
//
//        let isIntersected = (glyphRange.intersection(lineRange)?.length ?? 0) > 0
//        print("is intersected: ", isIntersected)
        
//        if let info = textView.textStorage?.attribute(.markdownInfo, at: charIndexes.pointee, effectiveRange: nil) as? [String: Any] {
//            print(info)
//            if info["type"] as! String == "codeblock" {
//                return 0
//            }
//        }
//
        
        // Make mutableProperties an optional to allow checking if it gets allocated
        let controlCharProps: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = UnsafeMutablePointer(mutating: props)
        
//        if let attribute = textStorage.attribute(.markdown, at: charIndexes.pointee, effectiveRange: nil) as? Int, attribute == 0 {
//
//        }
//
        var mutableGlymphRange = glyphRange
        
        
        
        
        for index in 0..<glyphRange.length {
            
            let charPtr = charIndexes[index]
//            var isMarkdown: Bool {
//                let attrValue = textStorage.attribute(.markdown, at: charPtr, effectiveRange: &mutableGlymphRange)
//                return attrValue != nil
//            }
            
            var isMarkdown: Bool {
                guard let a = textStorage.attribute(.markdown, at: charPtr, effectiveRange: &mutableGlymphRange) as? Int else { return false }
                return true
            }
            
            
//            print("isMarkdown", isMarkdown)
            
            if isMarkdown {
                // hide symbol
                if let controlCharProps = controlCharProps {
//                    print(controlCharProps[index])
                    controlCharProps[index] = NSLayoutManager.GlyphProperty.controlCharacter
                }
//                controlCharProps?[index] = .null
            }
            
//            let uniChar = (textStorage.string as NSString).character(at: charPtr)
//            if let unicodeScalar = UnicodeScalar(uniChar) {
//                print("unicodeScalar:", uniChar, Character(unicodeScalar))
////                if Character(unicodeScalar) == "*" {
////                    controlCharProps?[index] = .null
////                }
//            } else {
//                print("Not Unicode:", uniChar)
//                let font = textStorage.attribute(.font, at: charIndexes[index], effectiveRange: nil)
//                print(font)
////                if let fonttt = UIFont(name: "AppleColorEmoji", size: 24) {
////                    textStorage.addAttribute(.font, value: fonttt, range: glyphRange)
////                }
//                
//            }
//            print(textStorage.attribute(.markdown, at: charIndexes[index], effectiveRange: nil))
            
//            if textStorage.attribute(.markdown, at: charIndexes[index], effectiveRange: nil) != nil {
//
//            }
        }
        
        // Update only if mutableProperties was allocated
        if let newProps = controlCharProps {
            layoutManager.setGlyphs(glyphs, properties: newProps, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            return glyphRange.length
        }
        
        return glyphRange.length
    }
    
    
//    public func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSLayoutManager.ControlCharacterAction, forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction {
//
////        print(#function, action, charIndex)
//        
////        let glyphIndex = layoutManager.glyphIndexForCharacter(at: charIndex)
////        layoutManager.setNotShownAttribute(false, forGlyphAt: glyphIndex)
//        
////        return .zeroAdvancement
//        
//        return action
//    }
    
//    public func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
//        30
//    }
    
}
