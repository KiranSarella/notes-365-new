//
//  EditorView+ProcessSymbols.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import UIKit
import Combine


// MARK: - process markdown chars
extension EditorView {
    
    func processBold(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        let pattern = SymbolPattern.bold.rawValue
//        var boldFont = theme.font
//        boldFont = boldFont.apply(newTraits: .bold)
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            let regExCharLenght = 2
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                // foreground color
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            
//            innerAttributedString.addAttribute(.font,
//                                               value: boldFont,
//                                               range: styleRange)
            
            // update text color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // get markdown symbol start,end ranges
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // mark char as markdown start symbol, used to show/hide in layout delegate
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)
            
            // mark char as markdown end symbol, used to show/hide in layout delegate
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: endRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "bold"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.bold, range: match!.range)
        }
    }
    
    func processHighlight(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.highlight.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let regExCharLenght = 2
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                
                let highlightColor = theme.highlightColor.uiColor//.withAlphaComponent(0.45)
                
                // update text color
                innerAttributedString.addAttribute(.backgroundColor,
                                                   value: highlightColor, range: styleRange)
                
                // get markdown symbol start,end ranges
                let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
                let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
                // mark char as markdown start symbol, used to show/hide in layout delegate
                innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                   value: 0,
                                                   range: startRange)
                
                // mark char as markdown end symbol, used to show/hide in layout delegate
                innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                   value: 0,
                                                   range: endRange)
                
                let info: [String: Any] = [
                    "range": styleRange,
                    "type": "highlight"
                ]
                // info
                innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                   value: info,
                                                   range: styleRange)
                
                innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.highlight, range: match!.range)
            }
        }
    }
    
    
    func processItalic(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.italic.rawValue
        
//        var italicFont = theme.font
//        italicFont = italicFont.apply(newTraits: .italic)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
//            // font
//            innerAttributedString.addAttribute(.font,
//                                                    value: italicFont,
//                                                    range: styleRange)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits(.traitItalic) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
//                (  .apply(newTraits: .italicTrait)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // markdown
            let regExCharLenght = 1
            
            let markdownStartRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let markdownEndRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - padding, length: regExCharLenght)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.italic, range: match!.range)
        }
    }
    
    
    func processBoldAndItalic(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.boldAndItalic.rawValue
        
//        var italicFont = theme.font
//        italicFont = italicFont.apply(newTraits: [.italic, .bold])
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
            // font
//            innerAttributedString.addAttribute(.font,
//                                               value: italicFont,
//                                               range: styleRange)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // markdown
            let regExCharLenght = 3
            
            let markdownStartRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let markdownEndRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - padding, length: regExCharLenght)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.italic, range: match!.range)
        }
    }
    
    
    
    
//    func prepareRange(fullRange range: NSRange, formatLenght regExCharLenght: Int) -> (NSRange, NSRange) {
//
//        let regExCharLenght = 1
//
//        let markdownStartRange = NSRange(location: range.location, length: regExCharLenght)
//        let markdownEndRange = NSRange(location: range.location + range.length - regExCharLenght, length: regExCharLenght)
//
//        return (markdownStartRange, markdownEndRange)
//    }
    
   
    
    func processStrikethrough(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.strikethrough.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            // text color
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.styleColor.uiColor,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // strikethrough line
            innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // line color
            innerAttributedString.addAttribute(.strikethroughColor,
                                               value:  theme.styleColor.uiColor,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 2 , length: 2))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location + 1, length: match!.range.length - 1),
                "type": "strikethrough"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location + 1, length: match!.range.length - 1))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.strikethrough, range: match!.range)
        }
    }
    
    func processHttp(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = SymbolPattern.url

        
        let boldFont = theme.font
        //        let fontDesc = boldFont.fontDescriptor.withSymbolicTraits(.traitBold)
        //        boldFont = UIFont.boldSystemFont(ofSize: boldFont.pointSize)
        //        boldFont = boldFont.apply(newTraits: .bold)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        //        print(innerAttributedString.string.substring(with: extendedRange))
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let regExCharLenght = 0
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            
            innerAttributedString.addAttribute(.font,
                                               value: boldFont,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.blockQuoteColor.uiColor, range: styleRange)
        }
    }
    
    
    func processLink(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.link.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
//            innerAttributedString.addAttribute(.foregroundColor,
//                                               value:  theme.linkColor.uiColor,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineStyle,
//                                                    value:  NSUnderlineStyle.single.rawValue,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineColor,
//                                                    value:  theme.linkColor.uiColor,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.link, value: NSURL(string: "http://notes365.app")!, range: match!.range)
            
            innerAttributedString.addAttribute(.strokeColor,
                                               value:  UIColor.red,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.foregroundColor,
                                               value:  UIColor.red,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineStyle,
                                                                value:  NSUnderlineStyle.single.rawValue,
                                                                range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineColor,
                                                           value:  UIColor.red,
                                                                range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "link"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
         
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.link, range: match!.range)
        }
    }
    
    
    func processInlineCode(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.inlineCode.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            let font = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: UIFont.Weight.regular)
            let textRange = NSRange(location: match!.range.location + 1, length: match!.range.length - 2)
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                               range: textRange)
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.codeColor.uiColor,
                                                    range: textRange)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 1 , length: 1))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "inlinecode"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.inlineCode, range: match!.range)
        }
    }
    
    func canPocessCodeBlock(_ extendedRange: NSRange, _ innerAttributedString: NSTextStorage) -> (Int, Bool) {
        
        let pattern = SymbolPattern.codeBlockBalanceChecker.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        let numberOfMatches = regex.numberOfMatches(in: innerAttributedString.string, range: extendedRange)
//        print(numberOfMatches)
        if numberOfMatches == 0 {
            return (numberOfMatches, false)
        }
        
        return (numberOfMatches, numberOfMatches.isMultiple(of: 2))
        
//        return false
    }
    
    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        // continue if balanced only, else skip
        let (count, canProceed) = canPocessCodeBlock(extendedRange, textStorage)
        
        if canProceed == false {
            return
        }
        
        let pattern = SymbolPattern.codeBlock.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        // pairs count shoud match half of total single symbols
        let pairsCount = regex.numberOfMatches(in: innerAttributedString.string, range: extendedRange)
//        print(pairsCount)
        if pairsCount != (count / 2) {
            return
        }
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let fontM = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize - 2, weight: UIFont.Weight.regular)
            let font = UIFont(name: "Menlo", size: theme.font.pointSize - 2) ?? fontM
//            print("code#font", font)
            let textRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 6)
            
            // remove all existing attributes
            innerAttributedString.setAttributes([:], range: textRange)
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                               range: textRange)
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.codeColor.uiColor,
                                               range: textRange)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 3))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location + match!.range.length - 3 , length: 3))
            
            let fullRange = NSRange(location: match!.range.location, length: match!.range.length)
            
            let info: [String: Any] = [
                "range": fullRange,
                "type": "codeblock"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: fullRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.codeBlock, range: match!.range)
            
//            let textRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 6)
            

//            let endLength: Int = editorType == .smart ? 3 : 3
//            let lineRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 3)
            innerAttributedString.addAttribute(.codeBlockBackground, value: UIColor.orange, range: textRange)
            
            let para = NSMutableParagraphStyle()
            para.firstLineHeadIndent = 20
            para.headIndent = 20
            para.lineSpacing = 10
//            para.tailIndent = 10
            innerAttributedString.addAttribute(.paragraphStyle, value: para, range: textRange)
//            print(lineRange)
        }
    }
    
    
    func processOrderedList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.orderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(.font,
                                               value:  theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "orderedlist"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.orderedList, range: match!.range)
        }
        
    }
    
    
    func processUnorderedList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.unorderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value:  theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "unorderedlist"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.unorderedList, range: match!.range)
        }
    }
    
    func processCheckList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = SymbolPattern.checkList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value: theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "checkList"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
         
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.checkList, range: match!.range)
        }
    }
    
    func processBlockQuote(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        let pattern = SymbolPattern.blockQuote.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let fullRange = NSRange(location: match!.range.location, length: match!.range.length)
            
            innerAttributedString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }

                if font.familyName == theme.fontName {
                    let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                    let fallbackDescriptor = fontDesc?.addingAttributes([
                        UIFontDescriptor.AttributeName.name: theme.blockQuoteFontName
                    ])
                    let newFont = UIFont(descriptor: fallbackDescriptor ?? font.fontDescriptor, size: CGFloat(theme.fontSize))
                    innerAttributedString.addAttribute(.font, value: newFont, range: range)
                } else {
                    // leave to default font
                }
            }
            
            
//            let font =  theme.blockQuoteFontName
////            let fullRange = NSRange(location: match!.range.location, length: match!.range.length)
//            if let uifont = UIFont(name: font, size: CGFloat(theme.fontSize)) {
//                innerAttributedString.addAttribute(.font,
//                                                   value: uifont,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            }
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.blockQuoteColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "blockQuote"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.blockQuote, range: match!.range)
            
//            let val = editorType == .smart ? 2 : 1
            
            let lineRange = NSRange(location: match!.range.location + 2, length: match!.range.length - 2)
            logger.debug("lineRange: \(lineRange)")
            let bgInfo = [
                "code": "blockQuote",
                "color": theme.blockQuoteColor.uiColor
            ] as [String : Any]
            innerAttributedString.addAttribute(.blockQuoteBackground, value: bgInfo, range: lineRange)
            let para = NSMutableParagraphStyle()
            para.firstLineHeadIndent = 20
            para.headIndent = 20
            para.lineSpacing = 10
//            para.tailIndent = 10
            innerAttributedString.addAttribute(.paragraphStyle, value: para, range: fullRange)
        }
    }
    
    func processHeadings(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        styleHeading(symbolPattern: .h1, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 2, fontLevel: 1)
        styleHeading(symbolPattern: .h2, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 3, fontLevel: 2)
        styleHeading(symbolPattern: .h3, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 4, fontLevel: 3)
        styleHeading(symbolPattern: .h4, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 5, fontLevel: 4)
        styleHeading(symbolPattern: .h5, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 6, fontLevel: 5)
        styleHeading(symbolPattern: .h6, innerAttributedString: textStorage, extendedRange: extendedRange, symbolLenght: 7, fontLevel: 6)
        
    }
    
    func processHeadingsOld(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.paragraphSpacingBefore = 15
        paragraphStyle.paragraphSpacing = 5
        //            paragraphStyle.lineSpacing = 5
        
        let patternH1 = SymbolPattern.h1.rawValue
        
        let regex1a = try! NSRegularExpression(pattern: patternH1, options: [.anchorsMatchLines])
        
        regex1a.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let range = NSRange(location: match!.range.location + 2, length: match!.range.length - 2)
            
//            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                // bold
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 1))
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                // foreground color
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                print("enumerateAttribute: .font", range)
                let aStr = innerAttributedString.attributedSubstring(from: range)
                print(aStr.string)
                print(font)
                print(font.familyName, theme.fontName)
                
                if font.familyName == theme.fontName {
                    // apply new font
                    // bold
                    let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                    let fallbackDescriptor = fontDesc?.addingAttributes([
                        UIFontDescriptor.AttributeName.name: theme.headingFontName
                    ])
                    let newFont = UIFont(descriptor: fallbackDescriptor ?? font.fontDescriptor, size: getHeadingFontSize(level: 1))
                    innerAttributedString.addAttribute(.font, value: newFont, range: range)
                } else {
                    // bold
                    let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor
                    let newFont = UIFont(descriptor: fontDesc, size: getHeadingFontSize(level: 1))
                    innerAttributedString.addAttribute(.font, value: newFont, range: range)
                }
                
                
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }

            
            
//            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//
//                if let uifont = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 1)) {
//                    innerAttributedString.addAttribute(.font, value: uifont, range: range)
//                }
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            
//            if let uifont = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 1)) {
//                
//                let uifont = addFallbackToFont(font: uifont)
//                innerAttributedString.addAttribute(.font,
//                                                   value: uifont,
//                                                    range: range)
//            }
//            
//            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h1, range: match!.range)
        }
        
        
        
        let patternH2 = SymbolPattern.h2.rawValue
        
        let regex2 = try! NSRegularExpression(pattern: patternH2, options: [.anchorsMatchLines])
        
        regex2.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 3)
            
//            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 2))
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            if let h2Font = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 2)) {
                innerAttributedString.addAttribute(.font,
                                                   value: h2Font,
                                                    range: charRange)
            }
            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: charRange)
            
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 2)),
//                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemCyan,
//                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 3))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h2, range: match!.range)
        }
        
        
        let patternH3 = SymbolPattern.h3.rawValue
        
        let regex3 = try! NSRegularExpression(pattern: patternH3, options: [.anchorsMatchLines])
        
        regex3.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 4, length: match!.range.length - 4)
            
            if let h1Font = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 3)) {
                innerAttributedString.addAttribute(.font,
                                                   value: h1Font,
                                                    range: charRange)
            }
            
            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: charRange)
            
            
//            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 3))
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 3)),
//                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemTeal,
//                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 4))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h3, range: match!.range)
        }
        
        
        let patternH4 = SymbolPattern.h4.rawValue
        
        let regex4 = try! NSRegularExpression(pattern: patternH4, options: [.anchorsMatchLines])
        
        regex4.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 5, length: match!.range.length - 5)
            
//            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 4))
//                
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            
            if let h1Font = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 4)) {
                innerAttributedString.addAttribute(.font,
                                                   value: h1Font,
                                                    range: charRange)
            }
            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: charRange)
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 4)),
//                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemBrown,
//                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
            
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 5))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h4, range: match!.range)
        }
        
        
        let patternH5 = SymbolPattern.h5.rawValue
        
        let regex5 = try! NSRegularExpression(pattern: patternH5, options: [.anchorsMatchLines])
        
        regex5.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 6, length: match!.range.length - 6)
            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: charRange)
            
//            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 5))
//                
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            if let h1Font = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 5)) {
                innerAttributedString.addAttribute(.font,
                                                   value: h1Font,
                                                    range: charRange)
            }
            
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 5)),
//                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemIndigo,
//                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 6))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h5, range: match!.range)
        }
        
        let patternH6 = SymbolPattern.h6.rawValue
        
        let regex6 = try! NSRegularExpression(pattern: patternH6, options: [.anchorsMatchLines])
        
        regex6.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 7, length: match!.range.length - 7)
            
            innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: charRange)
            
//            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                
//                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
//                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 6))
//                
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
//            }
            
            
            if let h1Font = UIFont(name: theme.headingFontName, size: getHeadingFontSize(level: 6)) {
                innerAttributedString.addAttribute(.font,
                                                   value: h1Font,
                                                    range: charRange)
            }
            
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 6)),
//                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemMint,
//                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//
            
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 7))
            
            innerAttributedString.addAttribute(.markdownRange, value: SymbolPattern.h6, range: match!.range)
        }
    }
    
    func styleHeading(symbolPattern: SymbolPattern, innerAttributedString: NSTextStorage, extendedRange: NSRange, symbolLenght: Int, fontLevel: CGFloat) {
        
        let pattern = symbolPattern.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let fontSize = getHeadingFontSize(level: fontLevel)
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let range = NSRange(location: match!.range.location + symbolLenght, length: match!.range.length - symbolLenght)
            
            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
//                print("enumerateAttribute: .font", range)
                let aStr = innerAttributedString.attributedSubstring(from: range)
//                print(aStr.string)
//                print(font)
//                print(font.familyName, theme.fontName)
                
                if font.familyName == theme.fontName {
                    // apply new font
                    // bold
                    let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                    let fallbackDescriptor = fontDesc?.addingAttributes([
                        UIFontDescriptor.AttributeName.name: theme.headingFontName
                    ])
                    let newFont = UIFont(descriptor: fallbackDescriptor ?? font.fontDescriptor, size: fontSize)
                    innerAttributedString.addAttribute(.font, value: newFont, range: range)
                } else {
                    // bold
                    let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor
                    let newFont = UIFont(descriptor: fontDesc, size: fontSize)
                    innerAttributedString.addAttribute(.font, value: newFont, range: range)
                }
                
                
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }

            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: symbolLenght))
            
            innerAttributedString.addAttribute(.markdownRange, value: symbolPattern, range: match!.range)
        }
        
        
    }
    
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        
        let heading = MarkdownHeading(rawValue: Int(level))!
        return heading.getHeadingFontSize(baseFontSize: theme.font.pointSize)
    }
    
    /*
     
     + (UIFont *)addFallbacktoFont:(UIFont*)font{
        UIFontDescriptor* originalDescriptor = [font fontDescriptor];

        UIFontDescriptor* fallbackDescriptor = [originalDescriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorNameAttribute:@"Helvetica Neue"}];

        UIFontDescriptor* repaired = [originalDescriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorCascadeListAttribute:@[
                                                                                                 fallbackDescriptor
                                                                                                 ]}];

        font = [UIFont fontWithDescriptor:repaired size:0.0];

        return font;
     }
     
     */

    
    func addFallbackToFont(font: UIFont) -> UIFont {
        let originalDescriptor = font.fontDescriptor
        let fallbackDescriptor = originalDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.name: UIFont.systemFont(ofSize: 30)
        ])
        let repairedDescriptor = originalDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.cascadeList: [fallbackDescriptor]
        ])
        return UIFont(descriptor: repairedDescriptor, size: 0.0)
    }

}



