//
//  EditorViewDelegate.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 16/04/22.
//

#if os(macOS)

import AppKit


protocol EditorViewDelegate {

//    func markBold()
}


extension EditorView: EditorViewDelegate {
    
    func markBold(completion: () -> ()) {
        
//        self.textView.usesFindBar = true

//        button.tag = NSTextFinderAction.showFindInterface.rawValue
//        textview.performFindPanelAction(button)
        
//        textView.performFindPanelAction(nil)
        
        let selectedRange = textView.selectedRange()

        
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = "**\(substr)**"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
//        self.textView.showFindIndicator(for: selectedRange)
        
        completion()
    }
    
    
    func markItalic(completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = "*\(substr)*"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
        completion()
    }
    
    func headingFontChanged(fontName: String, completion: () -> ()) {
        
//        self.headingFontFamily = fontName
        
        // have to refresh entire editor
        // ?
        
        
        completion()
    }
    
    func markStrikethrough(completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = "~~\(substr)~~"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
        completion()
    }
    
    func markInline(completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = "`\(substr)`"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
        completion()
    }
    
    func markCodeblock(completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = "\n```\n\(substr)\n```\n"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
        completion()
    }
    
    func markBlockQuote(completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            let newStr = ">\(substr)"
            // add spaces if not exists
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
        }
        
        completion()
    }
    
    
    func updateTheme(theme: MarkdownTheme, completion: () -> ()) {
        
        self.theme = theme
        
        // refresh view
        self.textView.string = self.textView.string
        
        // refresh font again
        self.textView.font = theme.font
        self.textView.textColor = NSColor(theme.bodyColor.color)
        
        completion()
    }
    
    func insertImage(completion: () -> ()) {
        
//        let selectedRange = textView.textStorage?.editedRange
//        
//        if selectedRange.length == 0 {
//            return
//        }
        
        let img = Bundle.main.image(forResource: "one.png")
        
        let attachment = NSTextAttachment()
        attachment.image = img
        attachment.bounds = CGRect(x: 0, y: 0, width: 860, height: 540)
        let imageString = NSAttributedString(attachment: attachment)
        
        textView.textStorage?.append(imageString)
        
        completion()
//        textView.textStorage?.insert(imageString, at: selectedRange.location)
    }
    
    func clearFormat(completion: () -> ()) {
        
        // remove special chars
        // * # ~ `
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            
            let cleanStr = substr.replacingOccurrences(of: "[*#~`]", with: "", options: .regularExpression, range: nil)
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: cleanStr)
        }
        
        completion()
    }
    
    
    func heading(textStyle: TextStyleKey, completion: () -> ()) {
        
        let selectedRange = textView.selectedRange()
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.string as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            
            // append
            var newStr: String!
            
            if textStyle == .h1 {
                newStr = "# \(substr)"
            } else if textStyle == .h2 {
                newStr = "## \(substr)"
            } else if textStyle == .h3 {
                newStr = "### \(substr)"
            } else if textStyle == .h4 {
                newStr = "#### \(substr)"
            } else if textStyle == .h5 {
                newStr = "##### \(substr)"
            } else if textStyle == .h6 {
                newStr = "###### \(substr)"
            }
            
            self.textView.textStorage?.replaceCharacters(in: selectedRange, with: newStr)
            
            completion()
        }
        
    }
    
}

#endif
