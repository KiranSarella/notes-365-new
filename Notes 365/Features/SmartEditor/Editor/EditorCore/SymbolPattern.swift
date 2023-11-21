//
//  MarkdownPatterns.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 19/04/22.
//

import Foundation
import UIKit

public enum SymbolPattern: String {
    
//    case bold = #"\s\*\*([a-zA-Z0-9 .,]+)\*\*"#
    case body
//    case bold = #"(?<=(\B))(\*\*)([^*]+)\*\*\B[^*]"#
    case italic = #"(?<!\*)\B\*{1}(?!\*)([^\s])([^*]+)(?<!\*)\*{1}\B(?!\*)"#           // *italic*
//    case italic = #"(?<!\*)\B\*{1}(?!\*)([^*]+)(?<!\*)\*{1}\B(?!\*)"#           // *italic*
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!\*)([^(*|\n)]+)(?<!\*)\*{1}\B(?!\*)(?=(\^| |\n))"#
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!(\*| ))([^(*|\n)]+)(?<!(\*| ))\*{1}\B(?!\*)(?=($| |\n))"#
    
    case bold = #"(?<!\*)\B\*{2}(?!\*)([^\s])([^*]+)(?<!\*)\*{2}\B(?!\*)"#             // **bold**
    case highlight = #"(?<!\=)\B\={2}(?!\=)([^\s])([^=]+)(?<!\=)\={2}\B(?!\=)"#             // **bold**
//    case bold = #"(?<!\*)\B\*{2}(?!\*)([^*]+)(?<!\*)\*{2}\B(?!\*)"#             // **bold**
    case boldAndItalic = #"(?<!\*)\B\*{3}(?!\*)([^*]+)(?<!\*)\*{3}\B(?!\*)"#    // **bold and italic**
    case strikethrough = #"~~([^\s])(.*?)~~"#
    
    case h1 = #"((^#) ([^\s])(.+))"#
    case h2 = #"((^#{2}) ([^\s])(.+))"#
    case h3 = #"((^#{3}) ([^\s])(.+))"#
    case h4 = #"((^#{4}) ([^\s])(.+))"#
    case h5 = #"((^#{5}) ([^\s])(.+))"#
    case h6 = #"((^#{6}) ([^\s])(.+))"#
        
//    case orderedList =  #"^[[:blank:]]*?[0-9]+\.(.*)"#  //#"\n[0-9]+\.(.*)"#
    case orderedList =  #"^[[:blank:]]*?[0-9]+\."#  //#"\n[0-9]+\.(.*)"#
//    case unorderedList = #"^[[:blank:]]*?- ([^\[x \]].*)"# //#"\n\-(.*)"#
    case unorderedList = #"^[[:blank:]]*?- "# //#"\n\-(.*)"#
//    case checkList = #"(^[[:blank:]]?- )\[([ Xx])\] (.*)"#
    case checkList = #"(^[[:blank:]]*?- )\[([ Xx])\] "#
    
    // this will detect only inline
    // https://regexr.com/3cad6
//    case inlineCode = #"(?=`)`(?!`)[^`]*(?=`)`(?!`)"#
    
    
    case inlineCode = #"\B`([^\s])(.*?[^`])`(\B)"#
//    case inlineCode = #"\B`([^\s])(.*?[^`])`(\B)(?=( |\b|$|\s))"#
//    case inlineCode = #"\B`([^\s])(.*?)`(\B)(?=( |\b|$|\s))"#
    
    
//    case codeBlock = #"^`{3}([^\s])([\w]*)\n([\S\s]+?)\n^`{3}$"#
    case codeBlock = #"^`{3}([\w]*)\n([\S\s]+?)\n`{3}$"#
//    case codeBlock = #"^(`{3}.*[\n\r][^]*?^`{3})$"#
    case codeBlockBalanceChecker = #"^`{3}$"#
    
    case blockQuote = #"^(\>)([^\s])(.*)"#
//    case blockQuote = #"\n(\>)(.*)"#
    
    case link = #"\[([^\[]+)\]\(([^\)]+)\)"#
    
    case horizontalRule = #"\n-{5,}"#
}

extension SymbolPattern {
    // https://stackoverflow.com/a/73117746/2098686
    static let url = #"((https?:\/\/|ftp:\/\/|www\.)\S+\.[^()\n ]+((?:\([^)]*\))|[^.,;:?!"'\n\)\]<* ])+)"#
//    static let url = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
}

class EditorSettings {
    static let lineSpacing: CGFloat = 10
}
