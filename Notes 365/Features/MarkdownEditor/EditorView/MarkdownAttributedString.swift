//
//  MarkdownAttributedString.swift
//  Notes 365
//
//  Created by Kiran Sarella on 03/07/22.
//

import Foundation
import UIKit
// tree sitter parser
import SwiftTreeSitter
// markdown grammer
import TreeSitterMarkdown
import TreeSitterMarkdownInline



// using for view only - timeline
//  bcz of paragraph issue -- forgot the actual reason?
class MarkdownAttriburedString {
    
    let parser = Parser()
    
    var theme: MarkdownTheme
    
    var attrStrNew = AttributedString()
    
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
        
        var attrStr = NSMutableAttributedString(string: content, attributes: defaultAtts)
        
        
        blockParser(source: content, parser: parser, attrStr: &attrStr)
        inlineParser(source: content, parser: parser, attrStr: &attrStr)
        
        let fullRange = attrStr.fullRange()
        processBoldAndItalic(extendedRange: fullRange, textStorage: attrStr)
        processHttp(extendedRange: fullRange, textStorage: attrStr)
        
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
        
        var attrStr = NSMutableAttributedString(string: content, attributes: defaultAtts)
        
        
        blockParser(source: content, parser: parser, attrStr: &attrStr)
        inlineParser(source: content, parser: parser, attrStr: &attrStr)
         
        let fullRange = attrStr.fullRange()
        processBoldAndItalic(extendedRange: fullRange, textStorage: attrStr)
        processHttp(extendedRange: fullRange, textStorage: attrStr)
        
        return attrStr
    }

    // MAKR: - Tree-sitter
    
    func blockParser(source: String, parser: Parser,  attrStr: inout NSMutableAttributedString) {

        print(#function)
        
        let languageBlock = Language(language: tree_sitter_markdown())
        try? parser.setLanguage(languageBlock)

        let tree = parser.parse(source)!
        print("tree: ", tree)
        
        print(parser.includedRanges)
        guard let range = tree.rootNode?.byteRange else { return }
//        tree.rootNode?.range
//        parser.includedRanges
        
        tree.enumerateNodes(in: range) { node in
            
            print(node, node.range, node.nodeType!, node.byteRange, node.isNamed)
            
            if node.nodeType! == "atx_heading" {
                
                if let firstChild = node.firstChild {
                    let heading = firstChild.nodeType
                    
                    var fontSize: CGFloat = 52
                    
                    if heading == "atx_h1_marker" {
                        fontSize = getHeadingFontSize(level: 1)
                    }
                    else if heading == "atx_h2_marker" {
                        fontSize = getHeadingFontSize(level: 2)
                    }
                    else if heading == "atx_h3_marker" {
                        fontSize = getHeadingFontSize(level: 3)
                    }
                    else if heading == "atx_h4_marker" {
                        fontSize = getHeadingFontSize(level: 4)
                    }
                    else if heading == "atx_h5_marker" {
                        fontSize = getHeadingFontSize(level: 5)
                    }
                    else if heading == "atx_h6_marker" {
                        fontSize = getHeadingFontSize(level: 6)
                    }
                    
                    // bold
                    var boldFont = theme.font
                    if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitBold) {
                        boldFont = UIFont(descriptor: fontDesc, size: fontSize)
                    }
                    
                    // font
                    attrStr.addAttribute(.font, value: boldFont, range: node.range)
                    // color
                    attrStr.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: node.range)
                    // hide special chars
                    attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .thin), range: NSRange(location: firstChild.range.location, length: firstChild.range.length + 1))
                    
                }
                
                
            }
            
            else if node.nodeType! == "paragraph" {
                
//                attrStr.addAttribute(.font, value: theme.font, range: node.range)
//                attrStr.addAttribute(.foregroundColor, value: theme.bodyColor.uiColor, range: node.range)
            } else if node.nodeType! == "block_quote" {
                attrStr.addAttribute(.font, value: theme.font, range: node.range)
                attrStr.addAttribute(.foregroundColor, value: theme.blockQuoteColor.uiColor, range: node.range)
            } else if node.nodeType! == "block_quote_marker" {
                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .light), range: node.range)
            } else if node.nodeType! == "list_marker_minus" || node.nodeType! == "list_marker_dot" {
                attrStr.addAttribute(.foregroundColor, value: theme.listColor.uiColor, range: node.range)
            } else if node.nodeType! == "fenced_code_block" {
                
                let font = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: .regular)
                
                attrStr.addAttribute(.font, value: font, range: node.range)
                attrStr.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: node.range)
                
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.alignment = .center
                
                attrStr.addAttribute(.paragraphStyle, value: paraStyle, range: node.range)
            }
            
            
        }
        
        attrStrNew = AttributedString(attrStr)
    }
    
    func inlineParser(source: String, parser: Parser,  attrStr: inout NSMutableAttributedString) {

        print(#function)
        
        let languageInline = Language(language: tree_sitter_markdown_inline())
        try? parser.setLanguage(languageInline)

        let tree = parser.parse(source)!
        print("tree: ", tree)

        guard let range = tree.rootNode?.byteRange else { return }
        
        tree.enumerateNodes(in: range) { node in
            
            print(node, node.range, node.nodeType!, node.byteRange, node.isNamed)
            
            if node.nodeType! == "emphasis" {
                
                var italicFont = theme.font
                
                if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitItalic) {
                    italicFont = UIFont(descriptor: fontDesc, size: CGFloat(theme.fontSize))
                }
                
                attrStr.addAttribute(.font, value: italicFont, range: node.range)
                attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
            } else if node.nodeType! == "strong_emphasis" {
                var boldFont = theme.font
                if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitBold) {
                    boldFont = UIFont(descriptor: fontDesc, size: CGFloat(theme.fontSize))
                }
                
                // font
                attrStr.addAttribute(.font, value: boldFont, range: node.range)
                // color
                attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
            } else if node.nodeType! == "strikethrough" {
//                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 22), range: node.range)
                // foreground color
                attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
                // strikethroughStyle
                attrStr.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: node.range)
                // line color
                attrStr.addAttribute(.strikethroughColor, value: theme.styleColor.uiColor, range: node.range)
            } else if node.nodeType! == "code_span" {
                attrStr.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 22, weight: .regular), range: node.range)
                attrStr.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: node.range)
            } else if node.nodeType!.hasSuffix("delimiter") {
                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .ultraLight), range: node.range)
                attrStr.addAttribute(.foregroundColor, value: UIColor.clear, range: node.range)
            }
//            else if node.isNamed == false {
//                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 22, weight: .ultraLight), range: node.range)
//                attrStr.addAttribute(.foregroundColor, value: UIColor.gray, range: node.range)
//            }
            
        }
        
        attrStrNew = AttributedString(attrStr)
    }
    
    
    
    
    // MARK: - Process functions
    
     
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
    
    func processHttp(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.url
        
        var boldFont = theme.font
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
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        
        let heading = MarkdownHeading(rawValue: Int(level))!
        return heading.getHeadingFontSize(baseFontSize: CGFloat(theme.fontSize))
    }
}
