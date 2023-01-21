//
//  MarkdownPatterns.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 19/04/22.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum MarkdownPattern: String {
    
//    case bold = #"\s\*\*([a-zA-Z0-9 .,]+)\*\*"#
    case body
//    case bold = #"(?<=(\B))(\*\*)([^*]+)\*\*\B[^*]"#
    case italic = #"(?<!\*)\B\*{1}(?!\*)([^\s])([^*]+)(?<!\*)\*{1}\B(?!\*)"#           // *italic*
//    case italic = #"(?<!\*)\B\*{1}(?!\*)([^*]+)(?<!\*)\*{1}\B(?!\*)"#           // *italic*
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!\*)([^(*|\n)]+)(?<!\*)\*{1}\B(?!\*)(?=(\^| |\n))"#
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!(\*| ))([^(*|\n)]+)(?<!(\*| ))\*{1}\B(?!\*)(?=($| |\n))"#
    
    case bold = #"(?<!\*)\B\*{2}(?!\*)([^\s])([^*]+)(?<!\*)\*{2}\B(?!\*)"#             // **bold**
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
    
    case inlineCode = #"\B`([^\s])(.*?)`(\B)(?=( |\b|$|\s))"#
    case codeBlock = #"^`{3}([^\s])([\w]*)\n([\S\s]+?)\n^`{3}$"#
        
    // ^`{3}([\w]*)\n([\S\s]+?)\n`{3}$
    
    case blockQuote = #"^(\>)([^\s])(.*)"#
//    case blockQuote = #"\n(\>)(.*)"#
    
    case link = #"\[([^\[]+)\]\(([^\)]+)\)"#
    
    case horizontalRule = #"\n-{5,}"#
}


class EditorSettings {
    static let lineSpacing: CGFloat = 10
}
