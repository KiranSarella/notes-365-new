//
//  MarkdownStorage.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 15/04/22.
//

#if os(macOS)

import Foundation
import AppKit
import SwiftUI

public class MarkdownTextStorage: NSTextStorage {
    
    let baseFontSize: CGFloat = 16
    
    var innerAttributedString = NSMutableAttributedString()
    
    init(str: String = "") {
        innerAttributedString = NSMutableAttributedString(string: str)
        super.init()
        
        // font
//        self.font = NSFont.systemFont(ofSize: 24)
        self.font = NSFont.systemFont(ofSize: baseFontSize)
        // font color
        self.foregroundColor = NSColor.textColor
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
//        print("changeInLength", changeInLength)
        beginEditing()
        innerAttributedString.removeAttribute(name, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    public override func processEditing() {
        
        let extendedRange = (self.string as NSString).paragraphRange(for: editedRange)
        
//        removeAttribute(NSAttributedString.Key.font, range: editedRange)
        
//        removeAttribute(NSAttributedString.Key.font, range: <#T##NSRange#>)
        
        // cursor is moving to end
        removeAttribute(.font, range: editedRange)
        removeAttribute(.markdown, range: editedRange)
        removeAttribute(.foregroundColor, range: editedRange)
        removeAttribute(.strikethroughColor, range: editedRange)
        removeAttribute(.strikethroughStyle, range: editedRange)
        removeAttribute(.underlineColor, range: editedRange)
        removeAttribute(.underlineStyle, range: editedRange)
        removeAttribute(.paragraphStyle, range: editedRange)
        
//        removeAttribute(NSAttributedString.Key.foregroundColor, range: editedRange)

        // dark/light mode - auto textcolor to body text
        self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: NSColor.textColor,
                                                range: editedRange)
        
        
        
//        print("extended range: ", extendedRange)
        
        processBold(extendedRange: extendedRange)
        processItalic(extendedRange: extendedRange)
        processHeadings(extendedRange: extendedRange)
        processStrikethrough(extendedRange: extendedRange)
        processLink(extendedRange: extendedRange)
//        processQuote(extendedRange: extendedRange)
        
        processInlineCode(extendedRange: extendedRange)
        
        processOrderedList(extendedRange: extendedRange)
        processUnorderedList(extendedRange: extendedRange)
        processCheckList(extendedRange: extendedRange)
        
        processCodeBlock(extendedRange: extendedRange)
        processBlockQuote(extendedRange: extendedRange)
        
        super.processEditing()
    }
    
    func processBold(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.bold.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 1
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: baseFontSize),
                                                    range: styleRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "bold"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
//            print(info)
        }
    }
    
    func processItalic(extendedRange: NSRange) {
        
        // *italic*
        let pattern = MarkdownPattern.italic.rawValue
        
        let italicFont =
        NSFontManager.shared.font(withFamily: NSFont.systemFont(ofSize: baseFontSize, weight: .regular).familyName!, traits: .italicFontMask, weight: 0, size: baseFontSize)!
        
        
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
            
            
//            print(styleRange, markdownStartRange, markdownEndRange)
            
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
            
//            print(info)
        }
    }
    
    func processStrikethrough(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.strikethrough.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            // strikethrough
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.red,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                                    value:  NSColor.red,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            
            
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
                                                    value:  NSColor.blue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                                    value:  NSColor.blue,
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

    
//    func processQuote(extendedRange: NSRange) {
//        
//        let pattern = MarkdownPattern.quote.rawValue
//        
//        let regex = try! NSRegularExpression(pattern: pattern, options: [])
//        
//        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
//            match, flags, stop in
//            
//            // strikethrough
//            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value:  NSColor.green,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            
//            let info: [String: Any] = [
//                "range": NSRange(location: match!.range.location, length: match!.range.length),
//                "type": "quote"
//            ]
//            // info
//            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
//                                                    value: info,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            
//        }
//    }
    
    func processInlineCode(extendedRange: NSRange) {
        
        let pattern = MarkdownPattern.inlineCode.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            // strikethrough
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  NSColor.gray,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
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
                                                    value:  NSColor.systemGreen,
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
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        //        paragraphStyle.textBlocks = [SmartCodeBlock(), TweetTextBlock()]
//        paragraphStyle.textBlocks = [TweetTextBlock()]
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  NSFont.systemFont(ofSize: baseFontSize, weight: .medium),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  #colorLiteral(red: 0, green: 0.46, blue: 0.89, alpha: 1),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = 20
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
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

    
    func processHeadings(extendedRange: NSRange) {
        
        // bold
        //        let pattern = "\\s\\*\\*[\\p{Alphabetic}]+\\*\\*"
        //        let pattern = #"\s\*\*[\p{Alphabetic}]+\*\*"#
        // alphabets, numbers, space
        let patternH1 =  MarkdownPattern.h1.rawValue
        
        let regex = try! NSRegularExpression(pattern: patternH1, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 1)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "H1"
            ]
            
            // info
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
//            print(info)
            
        }
        
        let patternH2 = MarkdownPattern.h2.rawValue
        
        let regex2 = try! NSRegularExpression(pattern: patternH2, options: [.anchorsMatchLines])
        
        regex2.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 2)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        }
        
        let patternH3 = MarkdownPattern.h3.rawValue
        
        let regex3 = try! NSRegularExpression(pattern: patternH3, options: [.anchorsMatchLines])
        
        regex3.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 3)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        }
        
        let patternH4 = MarkdownPattern.h4.rawValue
        
        let regex4 = try! NSRegularExpression(pattern: patternH4, options: [.anchorsMatchLines])
        
        regex4.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 4)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        }
        
        let patternH5 = MarkdownPattern.h5.rawValue
        
        let regex5 = try! NSRegularExpression(pattern: patternH5, options: [.anchorsMatchLines])
        
        regex5.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 5)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        }
        
        let patternH6 = MarkdownPattern.h6.rawValue
        
        let regex6 = try! NSRegularExpression(pattern: patternH6, options: [.anchorsMatchLines])
        
        regex6.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 6)),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        }
        
    }
    
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        let fontSize: CGFloat = baseFontSize + (baseFontSize * 0.8) - (level * 2)
//        print(level, fontSize)
        return fontSize
    }
}

#endif
