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
    
    func markBold() {
        
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
        
        
    }
    
    
    func markItalic() {
        
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
        
        
    }
    
    func headingFontChanged(fontName: String) {
        
//        self.headingFontFamily = fontName
        
        // have to refresh entire editor
        // ?
        
        
        
    }
    
    func markStrikethrough() {
        
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
        
        
    }
    
    func markInline() {
        
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
        
        
    }
    
    func markCodeblock() {
        
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
        
        
    }
    
    func markBlockQuote() {
        
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
        
        
    }
    
    
    func updateTheme(theme: MarkdownTheme) {
        
        self.theme = theme
        
        // refresh view
        self.textView.string = self.textView.string
        
        // refresh font again
        self.textView.font = theme.font
        self.textView.textColor = NSColor(theme.bodyColor.color)
        
        
    }
    
    func insertImage() {
        
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
        
        
//        textView.textStorage?.insert(imageString, at: selectedRange.location)
    }
    
    func clearFormat() {
        
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
        
        
    }
    
    
    func heading(textStyle: TextStyleKey) {
        
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
            
            
        }
        
    }
    
}

#endif
