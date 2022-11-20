//
//  MyTextStorage.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 13/04/22.
//

#if os(macOS)

import Foundation
import AppKit

extension NSAttributedString.Key {
    static let markdown = NSAttributedString.Key(rawValue: "markdown")
    static let markdownRange = NSAttributedString.Key(rawValue: "markdown-range")
    static let markdownInfo = NSAttributedString.Key(rawValue: "markdown-info")
    
    static let defaultAttrubures = NSAttributedString.Key(rawValue: "default-attributes")
}

public class SmartTextStorage: NSTextStorage {
    
    
    
    let baseFontSize: CGFloat = 16
    
    var innerAttributedString = NSMutableAttributedString()
    
    init(str: String = "") {
        innerAttributedString = NSMutableAttributedString(string: str)
        super.init()
        
      
        
    }
    
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    
    public override var string: String {
        return innerAttributedString.string
    }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return innerAttributedString.attributes(at: location, effectiveRange: range)
    }
    
    fileprivate func clearAttributes(_ str: String, _ range: NSRange) {
        
        // check if edited char range is a markdown, if it is a markdown then check if it is still valid,
        // if not valid, remove attributes in the range
        
        let attributes = attributes(at: range.location - 2, longestEffectiveRange: nil, in: NSRange(location: range.location - 2, length: range.length))
        
        if attributes.keys.contains(NSAttributedString.Key.markdownInfo) {
            let info = attributes[NSAttributedString.Key.markdownInfo] as! [String: Any]
            
            guard
                let range1 = info["range"] as? NSRange,
                let type = info["type"] as? String
            else { return }
            
            if type == "bold" {
                // check if range is still bold
                let pattern = MarkdownPattern.bold.rawValue
                
                let str = (self.string as NSString).substring(with: range1)
                
                if str.range(of: pattern, options: .regularExpression) == nil {
                    // not a valid regex. so, remove attributes
                    removeAttribute(NSAttributedString.Key.font, range: range1)
                    removeAttribute(NSAttributedString.Key.markdownInfo, range: range1)
                    
                    // carrot position
                    edited(.editedAttributes, range: NSRange(location: range.location, length: range.length), changeInLength: str.count - range.length)
                }
            } else if type == "italic" {
                // check if range is still bold
                let pattern = MarkdownPattern.italic.rawValue
                
                let str = (self.string as NSString).substring(with: range1)
                
                if str.range(of: pattern, options: .regularExpression) == nil {
                    // not a valid regex. so, remove attributes
                    removeAttribute(NSAttributedString.Key.font, range: range1)
                    removeAttribute(NSAttributedString.Key.markdownInfo, range: range1)
                    
                    // carrot position
                    edited(.editedAttributes, range: NSRange(location: range.location, length: range.length), changeInLength: str.count - range.length)
                }
            }
        }
        
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        innerAttributedString.replaceCharacters(in: range, with:str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
        
//        if str == "" && range != NSRange() {
//            clearAttributes(str, range)
//        }
        
        endEditing()
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]!, range: NSRange) {
        beginEditing()
        innerAttributedString.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    public override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        beginEditing()
        innerAttributedString.removeAttribute(name, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    /// Switch used to prevent `processEditing` callbacks from
    /// within `processEditing`.
    fileprivate var isBusyProcessing = false

    fileprivate var addedDefaultAttrubures = false
    
    
    
    public override func processEditing() {
        
        self.isBusyProcessing = true
        defer { self.isBusyProcessing = false }

       
        if editedRange.length > 0 {
            let extendedRange = (self.string as NSString).paragraphRange(for: editedRange)
            
            
//            invalidateAttributes(in: extendedRange)
//            layoutManagers.first?.invalidateDisplay(forCharacterRange: extendedRange)
//
                // ** causing cursor moving to end, after every new char. insert
            removeAttribute(.font, range: extendedRange)
            removeAttribute(.markdown, range: extendedRange)
            removeAttribute(.foregroundColor, range: extendedRange)
            removeAttribute(.paragraphStyle, range: extendedRange)
            removeAttribute(.underlineColor, range: extendedRange)
            removeAttribute(.underlineStyle, range: extendedRange)
            
            
            
            // set default attibures
            // dark/light mode - auto textcolor to body text
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.textColor,
                                                    range: extendedRange)
            
            self.innerAttributedString.addAttribute(.font, value: NSFont.systemFont(ofSize: baseFontSize), range: extendedRange)

            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.minimumLineHeight = 10

            paragraphStyle.lineSpacing = 10

            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: extendedRange)


            
            processBold(extendedRange: extendedRange)
            processItalic(extendedRange: extendedRange)
            processHeadings(extendedRange: extendedRange)
            processStrikethrough(extendedRange: extendedRange)
            processLink(extendedRange: extendedRange)
            processInlineCode(extendedRange: extendedRange)
            
//            processOrderedList(extendedRange: extendedRange)
//            processUnorderedList(extendedRange: extendedRange)
//            processCheckList(extendedRange: extendedRange)
            
            processCodeBlock(extendedRange: extendedRange)
            processBlockQuote(extendedRange: extendedRange)
            
            
        }
        
        
        
        super.processEditing()
    }
    
    func processBold(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.bold.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let regExCharLenght = 2
//            let frontPadding = 0
            let backPadding = 1
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize),
                                                    range: styleRange)
            // markdown
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: startRange)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: endRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "bold"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
            
//            self.innerAttributedString.replaceCharacters(in: startRange, with: "")
//            self.innerAttributedString.replaceCharacters(in: endRange, with: "")
        }
    }
    
    func prepareRange(fullRange range: NSRange, formatLenght regExCharLenght: Int) -> (NSRange, NSRange) {
        
        let regExCharLenght = 1
        
        let markdownStartRange = NSRange(location: range.location, length: regExCharLenght)
        let markdownEndRange = NSRange(location: range.location + range.length - regExCharLenght, length: regExCharLenght)
        
        return (markdownStartRange, markdownEndRange)
    }
    
    func processItalic(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.italic.rawValue
        
        let italicFont =
        NSFontManager.shared.font(withFamily: NSFont.systemFont(ofSize: baseFontSize, weight: .regular).familyName!, traits: .italicFontMask, weight: 5, size: baseFontSize)!
        
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 1
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: italicFont,
                                                    range: styleRange)
            // markdown
            let regExCharLenght = 1
            
            let markdownStartRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let markdownEndRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - padding, length: regExCharLenght)
            
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownStartRange)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
            
        }
    }
    
    
    
    func processStrikethrough(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.strikethrough.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.systemRed,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                                    value:  NSColor.systemRed,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 2 , length: 2))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location + 1, length: match!.range.length - 1),
                "type": "strikethrough"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location + 1, length: match!.range.length - 1))
            
        }
    }
    
    
    func processLink(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.link.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            // strikethrough
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.systemBlue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                                    value:  NSColor.systemBlue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "link"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }
    
    
    func processInlineCode(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.inlineCode.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.systemGray,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 1 , length: 1))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "inlinecode"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }

    
    func processOrderedList(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.orderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize, weight: .regular),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.textColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "orderedlist"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }
    
    
    func processUnorderedList(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.unorderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize, weight: .regular),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.textColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "unorderedlist"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }
    
    func processCheckList(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.checkList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize, weight: .regular),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.textColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "checkList"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }

    
    func processCodeBlock(extendedRange: NSRange) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
        
        let globalBlock = NSTextBlock()
        globalBlock.setWidth(140, type: .absoluteValueType, for: .padding, edge: .minX)
        globalBlock.setContentWidth(100, type: .percentageValueType)
        
        let paddingTextCodeBlock = NSTextBlock()
        paddingTextCodeBlock.setContentWidth(80, type: .percentageValueType)
//        paddingTextCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        paddingTextCodeBlock.setBorderColor(.red)
        paddingTextCodeBlock.setWidth(1, type: .absoluteValueType, for: .border)
//        paddingTextCodeBlock.setWidth(20, type: .absoluteValueType, for: .padding, edge: .minX)
        paddingTextCodeBlock.backgroundColor = NSColor.yellow
        
        
        let textCodeBlock = NSTextBlock()
        textCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        textCodeBlock.backgroundColor = NSColor.gray
//        textCodeBlock.setWidth(20, type: .absoluteValueType, for: .margin)
        textCodeBlock.setContentWidth(60, type: .percentageValueType)
        
        
//        let codeBlock = TweetTextBlock()
        
        paragraphStyle.textBlocks = [globalBlock, paddingTextCodeBlock]
        
//        paragraphStyle.textBlocks = [codeBlock]
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
//            if let paraS = self.innerAttributedString.attribute(.paragraphStyle, at: match!.range.location, effectiveRange: nil) as? NSParagraphStyle {
//
//                paragraphStyle.appen
//
//            }
//
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize - 2, weight: .medium),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  #colorLiteral(red: 0, green: 0.46, blue: 0.89, alpha: 1),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: match!.range.location, length: match!.range.length))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 3))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 3 , length: 3))
            
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "codeblock"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }
    
    func processBlockQuote(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.blockQuote.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize, weight: .semibold),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.systemTeal,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length, length: 1))
            
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "blockQuote"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
        }
    }
    
    func processHeadings(extendedRange: NSRange) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.paragraphSpacingBefore = 15
        paragraphStyle.paragraphSpacing = 5
        //            paragraphStyle.lineSpacing = 5
        
        
        let patternH1 = MarkdownPattern.h1.rawValue
        
        let regex1a = try! NSRegularExpression(pattern: patternH1, options: [.anchorsMatchLines])
        
        regex1a.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let range = NSRange(location: match!.range.location + 2, length: match!.range.length - 2)
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 1)),
                                                    range: range)
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.textColor,
                                                    range: range)

//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
        }
        
        
        let patternH2 = MarkdownPattern.h2.rawValue
        
        let regex2 = try! NSRegularExpression(pattern: patternH2, options: [.anchorsMatchLines])
        
        regex2.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 2)),
                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.systemCyan,
                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 3))
            
        }
        
        
        let patternH3 = MarkdownPattern.h3.rawValue
        
        let regex3 = try! NSRegularExpression(pattern: patternH3, options: [.anchorsMatchLines])
        
        regex3.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 3)),
                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.systemTeal,
                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 4))
            
        }
        
        
        let patternH4 = MarkdownPattern.h4.rawValue
        
        let regex4 = try! NSRegularExpression(pattern: patternH4, options: [.anchorsMatchLines])
        
        regex4.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 4)),
                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.systemBrown,
                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 5))
        }
        
        
        let patternH5 = MarkdownPattern.h5.rawValue
        
        let regex5 = try! NSRegularExpression(pattern: patternH5, options: [.anchorsMatchLines])
        
        regex5.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 5)),
                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.systemIndigo,
                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 6))
        }
        
        let patternH6 = MarkdownPattern.h6.rawValue
        
        let regex6 = try! NSRegularExpression(pattern: patternH6, options: [.anchorsMatchLines])
        
        regex6.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 6)),
                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: NSColor.systemMint,
                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//            self.innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 7))
        }
    }
    
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        let fontSize: CGFloat = baseFontSize + (baseFontSize * 0.8) - (level * 2)
//        print(level, fontSize)
        return fontSize
    }
    
}


class SmartCodeBlock: NSTextBlock {
    
    override init() {
        super.init()
        
//        setWidth(15.0, type: .absoluteValueType, for: .padding)
//        setWidth(45.0, type: .absoluteValueType, for: .padding, edge: .minY)
        
        backgroundColor = NSColor(white: 0.95, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func drawBackground(withFrame frameRect: NSRect, in controlView: NSView, characterRange charRange: NSRange, layoutManager: NSLayoutManager) {
//
//        let adjustedFrame: NSRect = frameRect
//        super.drawBackground(withFrame: adjustedFrame, in: controlView, characterRange: charRange, layoutManager: layoutManager)
//
//        let drawPoint: NSPoint = NSPoint.init(x: 10, y: 10)
//        let drawString = NSString(string: "Swift Code")
//        let attributes = [NSAttributedString.Key.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), .foregroundColor: NSColor.blue]
//        drawString.draw(at: drawPoint, withAttributes: attributes)
//    }
}


class TweetTextBlock: NSTextBlock {
    
    override init() {
        super.init()
        
        // outer padding
        
        setWidth(30.0, type: .absoluteValueType, for: .padding)
        setWidth(30, type: .absoluteValueType, for: .margin)
//        setWidth(45.0, type: .absoluteValueType, for: .padding, edge: .minY)
//
////        setWidth(15.0, type: .absoluteValueType, for: .padding)
//        setWidth(70.0, type: .absoluteValueType, for: .padding, edge: .minX)
//
//        setValue(20, type: .absoluteValueType, for: .minimumHeight)
//
//        setValue(500, type: .absoluteValueType, for: .width)
//        setValue(590, type: .absoluteValueType, for: .maximumWidth)
        
//        setWidth(30, type: .absoluteValueType, for: .border, edge: .minX)
//        setWidth(30, type: .absoluteValueType, for: .border, edge: .maxY)
        
        
        setWidth(1, type: .absoluteValueType, for: .border)
        setBorderColor(NSColor.gray)
        
        
//        backgroundColor = NSColor(white: 0.97, alpha: 1.0)
        
//        verticalAlignment = .middleAlignment
        
        setContentWidth(100, type: .percentageValueType)
        
    }
    
    
    
    
//    override func drawBackground(withFrame frameRect: NSRect, in controlView: NSView,
//                                 characterRange charRange: NSRange, layoutManager: NSLayoutManager) {
//
//        let frame = frameRect
//        super.drawBackground(withFrame: frame, in: controlView, characterRange:
//                                charRange, layoutManager: layoutManager)
//
////        // draw string
////        let fo = frameRect.origin
////        let context = NSGraphicsContext.current
////        context?.shouldAntialias = true
//
////        let drawPoint: NSPoint = CGPoint(x: fo.x + 70, y: fo.y + 10)
//
//
////        let nameAttributes = [NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-Bold", size: 15),  .foregroundColor: NSColor.black]
////        var handleAttributes = [NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 15),  .foregroundColor: NSColor(red: 0.3936756253, green: 0.4656872749, blue: 0.5323709249, alpha: 1)]
//
////        let nameAStr = NSMutableAttributedString(string: "Johanna Appleseed", attributes: nameAttributes)
////        let handleAStr = NSAttributedString(string: "  @johappleseed ·  3h", attributes: handleAttributes)
////        nameAStr.append(handleAStr)
////        nameAStr.draw(at: drawPoint)
//
////        let im = NSImage(named: "profile-twitter")!
////        im.draw(in: NSRect(x: fo.x + 10, y: fo.y + 10, width: 50, height: 50))
////
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


#endif
