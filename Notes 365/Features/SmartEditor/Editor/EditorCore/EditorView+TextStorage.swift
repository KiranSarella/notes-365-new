//
//  EditorView+NSTextStorageDelegate.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//
import UIKit
import Combine

extension EditorView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        let extendedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)
    }
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
     
//        print("editedRange", editedRange, "delta", delta, "editedMask", editedMask)
   
        let extendedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
//        textStorage.setAttributes([:], range: extendedRange)
        // FIXIT: - ** if enabled, telugu font will not work. if disabled, code block and below lines font issue.
//        textStorage.removeAttribute(.font, range: extendedRange)
        textStorage.removeAttribute(.markdown, range: extendedRange)
        textStorage.removeAttribute(.markdownRange, range: extendedRange)
        textStorage.removeAttribute(.foregroundColor, range: extendedRange)
//        textStorage.removeAttribute(.paragraphStyle, range: extendedRange)
        textStorage.removeAttribute(.underlineColor, range: extendedRange)
        textStorage.removeAttribute(.underlineStyle, range: extendedRange)
        
        textStorage.removeAttribute(.codeBlockBackground, range: extendedRange)
        textStorage.removeAttribute(.blockQuoteBackground, range: extendedRange)
        textStorage.removeAttribute(.paragraphStyle, range: extendedRange)
        
        textStorage.addAttribute(.markdownRange, value: SymbolPattern.body, range: extendedRange)
        
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 10
        textStorage.addAttribute(.paragraphStyle, value: para, range: extendedRange)
        
        // FIXIT: - ** if enabled, telugu font will not work. if disabled, code block and below lines font
//        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)

        
//        let font = textStorage.attribute(.font, at: 0, effectiveRange: &extendedRange)
//        print(font)
////        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)
//        let font2 = textStorage.attribute(.font, at: 0, effectiveRange: &extendedRange)
//        print(font2)
        
        
//        print("after:", bodyFont.fontDescriptor.symbolicTraits, extendedRange)
//
        textStorage.addAttribute(.foregroundColor, value: theme.bodyColor.uiColor, range: extendedRange)

        
//        textStorage.enumerateAttributes(in: extendedRange) { attribureKeys, range, pointer in
//            print(attribureKeys, range)
//        }
        
        // ** order by preferenced - low to high
        processBlockQuote(extendedRange: extendedRange, textStorage: textStorage)
        processHeadings(extendedRange: extendedRange, textStorage: textStorage)
        
        processOrderedList(extendedRange: extendedRange, textStorage: textStorage)
        processUnorderedList(extendedRange: extendedRange, textStorage: textStorage)
        processCheckList(extendedRange: extendedRange, textStorage: textStorage)
        
        processItalic(extendedRange: extendedRange, textStorage: textStorage)   // *
        processBold(extendedRange: extendedRange, textStorage: textStorage)     // **
        processHighlight(extendedRange: extendedRange, textStorage: textStorage)     // **
        processBoldAndItalic(extendedRange: extendedRange, textStorage: textStorage)    // ***
        processStrikethrough(extendedRange: extendedRange, textStorage: textStorage)
//        processLink(extendedRange: extendedRange, textStorage: textStorage)
        processInlineCode(extendedRange: extendedRange, textStorage: textStorage)
        processHttp(extendedRange: extendedRange, textStorage: textStorage)
        let fullRange = textStorage.fullRange()
        if fullRange.length > 0 {
            processCodeBlock(extendedRange: textStorage.fullRange(), textStorage: textStorage)
        }
    }
    
    
    
    
   
  
}
