//
//  MyTextStorage.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 13/04/22.
//

#if os(iOS)

import Foundation
import UIKit

extension NSAttributedString.Key {
    static let markdown = NSAttributedString.Key(rawValue: "markdown")
    static let markdownRange = NSAttributedString.Key(rawValue: "markdown-range")
    static let markdownInfo = NSAttributedString.Key(rawValue: "markdown-info")
}

public class SmartTextStorage: NSTextStorage {
    
    var innerAttributedString = NSMutableAttributedString()
    
    init(str: String = "") {
        innerAttributedString = NSMutableAttributedString(string: str)
        
        super.init()
        
        // font
        //        self.font = UIFont(name: "Chalkduster", size: 24)
//        self.font = UIFont.systemFont(ofSize: 18)
        // font color
        //        self.foregroundColor = UIColor.systemRed
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
//        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
//    }
    
    
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
    
    
    public override func processEditing() {
        
        if editedRange.length > 0 {
            let extendedRange = (self.string as NSString).paragraphRange(for: editedRange)
            
            
            //            invalidateAttributes(in: extendedRange)
            //            layoutManagers.first?.invalidateDisplay(forCharacterRange: extendedRange)
            //
            // ** causing cursor moving to end, after every new char. insert
            removeAttribute(NSAttributedString.Key.font, range: editedRange)
            removeAttribute(NSAttributedString.Key.markdown, range: editedRange)
            removeAttribute(NSAttributedString.Key.foregroundColor, range: editedRange)
            
            // dark/light mode - auto textcolor to body text
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.label,
                                                    range: editedRange)
            
            
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
                                                    value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
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
        
        let italicFont = UIFont.italicSystemFont(ofSize: 18)
//        UIFontManager.shared.font(withFamily: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular).familyName!, traits: .italicFontMask, weight: 0, size: 18)!
        
        
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
                                                    value:  UIColor.systemRed,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                                    value:  UIColor.systemRed,
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
                                                    value:  UIColor.systemBlue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            self.innerAttributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                                    value:  UIColor.systemBlue,
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
                                                    value:  UIColor.systemGray,
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
                                                    value:  UIFont.systemFont(ofSize: 14, weight: .light),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  UIColor.label,
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
                                                    value:  UIFont.systemFont(ofSize: 14, weight: .light),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  UIColor.label,
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
                                                    value:  UIFont.systemFont(ofSize: 14, weight: .light),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  UIColor.label,
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
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value:  UIFont.systemFont(ofSize: 12, weight: .medium),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  #colorLiteral(red: 0, green: 0.46, blue: 0.89, alpha: 1),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
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
                                                    value:  UIFont.systemFont(ofSize: 20, weight: .semibold),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value:  UIColor.systemTeal,
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
        
        let patternH1 = MarkdownPattern.h1.rawValue
        
        let regex1a = try! NSRegularExpression(pattern: patternH1, options: [.anchorsMatchLines])
        
        regex1a.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            self.innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                                    value: UIFont.boldSystemFont(ofSize: 32),
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 2))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.label,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 2))
            
            
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
                                                    value: UIFont.boldSystemFont(ofSize: 28),
                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.systemCyan,
                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
            
            
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
                                                    value: UIFont.boldSystemFont(ofSize: 24),
                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.systemTeal,
                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
            
            
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
                                                    value: UIFont.boldSystemFont(ofSize: 20),
                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.systemBrown,
                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
            
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
                                                    value: UIFont.boldSystemFont(ofSize: 18),
                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.systemIndigo,
                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
            
            
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
                                                    value: UIFont.boldSystemFont(ofSize: 16),
                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
            
            self.innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                    value: UIColor.systemMint,
                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
            
            
            // add id key
            self.innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 7))
        }
    }
    
    
}


#endif
