//
//  MarkdownAttributedString.swift
//  Notes 365
//
//  Created by Kiran Sarella on 03/07/22.
//

import Foundation
import UIKit

// using for view only - timeline
//  bcz of paragraph issue -- forgot the actual reason?
class MarkdownAttriburedString {
    
    var theme: MarkdownTheme
    
    
    init(theme: MarkdownTheme) {
        self.theme = theme
    }
    
    func getAttriburedStringAsync(forMarkdown content: String) async -> NSAttributedString {
        
//        print(#function)
        
        let content = content.trimmingCharacters(in: .newlines)
        
        if content.count == 0 {
            return NSAttributedString()
        }
        
        // default attrubutes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let defaultAtts: [NSAttributedString.Key: Any] = [
            .font: theme.font,
            .foregroundColor: theme.bodyColor.uiColor,// theme.bodyColor.uiColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attrStr = NSMutableAttributedString(string: content, attributes: defaultAtts)
        
        
        //        let fulR = attrStr.string.range(of: attrStr.string)
        
        let fullRange = attrStr.fullRange()
        //        let fullRange = NSRange(location: 0, length: content.count)
        
        //        let fullRange = NSRange(location: 0, length: content.count)
        
        
        processHeadings(extendedRange: fullRange, textStorage: attrStr)
        processBlockQuote(extendedRange: fullRange, textStorage: attrStr)
        
        processOrderedList(extendedRange: fullRange, textStorage: attrStr)
        processUnorderedList(extendedRange: fullRange, textStorage: attrStr)
        processCheckList(extendedRange: fullRange, textStorage: attrStr)
        
        processBold(extendedRange: fullRange, textStorage: attrStr)
        processItalic(extendedRange: fullRange, textStorage: attrStr)
        processBoldAndItalic(extendedRange: fullRange, textStorage: attrStr)
        processStrikethrough(extendedRange: fullRange, textStorage: attrStr)
        
        //        processLink(extendedRange: fullRange, textStorage: attrStr)
        
        processInlineCode(extendedRange: fullRange, textStorage: attrStr)
        processCodeBlock(extendedRange: fullRange, textStorage: attrStr)
        
        
        
        return attrStr
        
    }
    
    func getAttriburedString(forMarkdown content: String) -> NSAttributedString {
        
        let content = content.trimmingCharacters(in: .newlines)
        
        if content.count == 0 {
            return NSAttributedString()
        }
        
        // default attrubutes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let defaultAtts: [NSAttributedString.Key: Any] = [
            .font: theme.font,
            .foregroundColor: theme.bodyColor.uiColor,//theme.bodyColor.uiColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attrStr = NSMutableAttributedString(string: content, attributes: defaultAtts)
        
        
//        let fulR = attrStr.string.range(of: attrStr.string)
        
        let fullRange = attrStr.fullRange()
//        let fullRange = NSRange(location: 0, length: content.count)

//        let fullRange = NSRange(location: 0, length: content.count)
        
        // ** order by preferenced - low to high
        processBlockQuote(extendedRange: fullRange, textStorage: attrStr)
        processHeadings(extendedRange: fullRange, textStorage: attrStr)
        
        processItalic(extendedRange: fullRange, textStorage: attrStr)
        processBold(extendedRange: fullRange, textStorage: attrStr)
        processBoldAndItalic(extendedRange: fullRange, textStorage: attrStr)
        processStrikethrough(extendedRange: fullRange, textStorage: attrStr)
        
//        processLink(extendedRange: fullRange, textStorage: attrStr)
        
        processOrderedList(extendedRange: fullRange, textStorage: attrStr)
        processUnorderedList(extendedRange: fullRange, textStorage: attrStr)
        processCheckList(extendedRange: fullRange, textStorage: attrStr)
        
        
        
        processInlineCode(extendedRange: fullRange, textStorage: attrStr)
        processCodeBlock(extendedRange: fullRange, textStorage: attrStr)
        
        
        
        return attrStr

    }

    
    
    func processBold(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.bold.rawValue
        
        var boldFont = theme.font
//        let fontDesc = boldFont.fontDescriptor.withSymbolicTraits(.traitBold)
        boldFont = UIFont.boldSystemFont(ofSize: boldFont.pointSize)
//        boldFont = boldFont.apply(newTraits: .bold)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
//        print(innerAttributedString.string.substring(with: extendedRange))
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let regExCharLenght = 2
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            
            innerAttributedString.addAttribute(.font,
                                               value: boldFont,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            
            // markdown
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: endRange)
            
          
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: startRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: endRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "bold"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.bold, range: match!.range)
        }
    }
    
    
    func processItalic(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.italic.rawValue
        
        var italicFont = theme.font
//        let fontDesc = italicFont.fontDescriptor.withSymbolicTraits(.traitItalic)
        italicFont = UIFont.italicSystemFont(ofSize: italicFont.pointSize)
//        italicFont = italicFont.apply(newTraits: .italic)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length)
            // font
            innerAttributedString.addAttribute(.font,
                                               value: italicFont,
                                               range: styleRange)
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
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.italic, range: match!.range)
        }
    }
    
    
    
    func processBoldAndItalic(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.boldAndItalic.rawValue
        
        var italicFont = theme.font
        let fontDesc = italicFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])
        italicFont = UIFont(descriptor: fontDesc ?? italicFont.fontDescriptor, size: italicFont.pointSize)
//        italicFont = italicFont.apply(newTraits: [.italic, .bold])
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length)
            // font
            innerAttributedString.addAttribute(.font,
                                               value: italicFont,
                                               range: styleRange)
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
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.italic, range: match!.range)
        }
    }
    
    
    
    func processStrikethrough(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.strikethrough.rawValue
        
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
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 2))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location + match!.range.length - 2 , length: 2))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location + 1, length: match!.range.length - 1),
                "type": "strikethrough"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location + 1, length: match!.range.length - 1))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.strikethrough, range: match!.range)
        }
    }
    
    
    func processLink(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.link.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value:  UIColor.systemBlue,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.underlineStyle,
                                               value:  NSUnderlineStyle.single.rawValue,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.underlineColor,
                                               value:  UIColor.systemBlue,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "link"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.link, range: match!.range)
        }
    }
    
    
    func processInlineCode(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.inlineCode.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value:  UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: UIFont.Weight.medium),
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value: theme.codeColor.uiColor,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location + match!.range.length - 1 , length: 1))
       
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location + match!.range.length - 1 , length: 1))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "inlinecode"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.inlineCode, range: match!.range)
        }
    }
    
    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value:  UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: UIFont.Weight.medium),
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value: theme.codeColor.uiColor,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 3))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location + match!.range.length - 3, length: 3))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 3))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location + match!.range.length - 3, length: 3))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "codeblock"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.inlineCode, range: match!.range)
        }
    }
    
    func processOrderedList(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.orderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(.font,
                                               value:  theme.font,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value: theme.listColor.uiColor,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "orderedlist"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.orderedList, range: match!.range)
        }
        
    }
    
    
    func processUnorderedList(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.unorderedList.rawValue
        
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
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.unorderedList, range: match!.range)
        }
    }
    
    func processCheckList(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.checkList.rawValue
        
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
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.checkList, range: match!.range)
        }
    }
    
    
    /*
    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {


        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10

        let globalBlock = NSTextBlock()
        globalBlock.setWidth(140, type: .absoluteValueType, for: .padding, edge: .minX)
        globalBlock.setContentWidth(100, type: .percentageValueType)

        let paddingTextCodeBlock = NSTextBlock()
        paddingTextCodeBlock.setContentWidth(80, type: .percentageValueType)
        //        paddingTextCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        paddingTextCodeBlock.setBorderColor(.gray)
        paddingTextCodeBlock.setWidth(1, type: .absoluteValueType, for: .border)
        //        paddingTextCodeBlock.setWidth(20, type: .absoluteValueType, for: .padding, edge: .minX)
        paddingTextCodeBlock.backgroundColor = UIColor.lightGray


        let textCodeBlock = NSTextBlock()
        textCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        textCodeBlock.backgroundColor = UIColor.lightGray
        //        textCodeBlock.setWidth(20, type: .absoluteValueType, for: .margin)
        textCodeBlock.setContentWidth(60, type: .percentageValueType)


        //        let codeBlock = TweetTextBlock()

        paragraphStyle.textBlocks = [globalBlock, paddingTextCodeBlock]

        //        paragraphStyle.textBlocks = [codeBlock]

        let pattern = MarkdownPattern.codeBlock.rawValue

        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])

        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in

            let range = NSRange(location: match!.range.location, length: match!.range.length)

            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }

                /*
                 // remove traits
                 let fontDescriptor = font.fontDescriptor
                 var traits = fontDescriptor.symbolicTraits
                 if traits.contains(.italic) {
                 traits = traits.remove(.italic)!
                 }
                 if traits.contains(.bold) {
                 traits = traits.remove(.bold)!
                 }
                 let fontDesc = fontDescriptor.withSymbolicTraits(traits)
                 // add traits
                 guard let font2 = UIFont(descriptor: fontDesc, size: CGFloat(theme.font.pointSize - 2)) else { return }

                 let newFont = font2.apply(newTraits: .monoSpace, newPointSize: CGFloat(theme.font.pointSize - 2))
                 // remove existing traits

                 */

                // bold
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitMonoSpace)
                let newFont = UIFont(descriptor: fontDesc!, size: CGFloat(theme.font.pointSize - 2))

//                let newFont = font.apply(newTraits: .monoSpace, newPointSize: CGFloat(theme.font.pointSize - 2))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: range)
            }

            //            var font = UIFont(name: theme.codeFontName, size: CGFloat(theme.bodyFontSize - 2))
            ////            font = font.apply(newTraits: .expanded)
            //
            //            innerAttributedString.addAttribute(.font,
            //                                                    value:  font,
            //                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            //
            //            innerAttributedString.addAttribute(.foregroundColor,
            //                                               value:  theme.codeBlockColor),
            //                                                    range: NSRange(location: match!.range.location, length: match!.range.length))


            let regExCharLenght = 3
            let backPadding = 0
            // markdown
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)

            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: endRange)

            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: startRange)

            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: endRange)


            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "codeblock"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))

            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.codeBlock, range: match!.range)
        }
    }
     */

    func processBlockQuote(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.blockQuote.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let font =  theme.font
            
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.blockQuoteColor.uiColor,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
//                                               value: 0,
//                                               range: NSRange(location: match!.range.location, length: 1))
//
//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
//                                               value: 0,
//                                               range: NSRange(location: match!.range.location + match!.range.length, length: 1))
//
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 1))

//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                               value: UIFont.systemFont(ofSize: 0.1),
//                                               range: NSRange(location: match!.range.location + match!.range.length, length: 1))
//
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "blockQuote"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.blockQuote, range: match!.range)
        }
    }
    
    func processHeadings(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        
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
            
            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 1))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 2))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 2))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h1, range: match!.range)
        }
        
        
        
        let patternH2 = MarkdownPattern.h2.rawValue
        
        let regex2 = try! NSRegularExpression(pattern: patternH2, options: [.anchorsMatchLines])
        
        regex2.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 3)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 2))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
        
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 3))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 3))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h2, range: match!.range)
        }
        
        
        let patternH3 = MarkdownPattern.h3.rawValue
        
        let regex3 = try! NSRegularExpression(pattern: patternH3, options: [.anchorsMatchLines])
        
        regex3.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 4, length: match!.range.length - 4)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 3))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
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
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 4))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h3, range: match!.range)
        }
        
        
        let patternH4 = MarkdownPattern.h4.rawValue
        
        let regex4 = try! NSRegularExpression(pattern: patternH4, options: [.anchorsMatchLines])
        
        regex4.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 5, length: match!.range.length - 5)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 4))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
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
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 5))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h4, range: match!.range)
        }
        
        
        let patternH5 = MarkdownPattern.h5.rawValue
        
        let regex5 = try! NSRegularExpression(pattern: patternH5, options: [.anchorsMatchLines])
        
        regex5.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 6, length: match!.range.length - 6)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 5))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
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
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 6))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h5, range: match!.range)
        }
        
        let patternH6 = MarkdownPattern.h6.rawValue
        
        let regex6 = try! NSRegularExpression(pattern: patternH6, options: [.anchorsMatchLines])
        
        regex6.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 7, length: match!.range.length - 7)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 6))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
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
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: UIFont.systemFont(ofSize: 0.1),
                                               range: NSRange(location: match!.range.location, length: 7))
            
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h6, range: match!.range)
        }
    }
    
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        
        let heading = MarkdownHeading(rawValue: Int(level))!
        return heading.getHeadingFontSize(baseFontSize: theme.font.pointSize)
    }
}
