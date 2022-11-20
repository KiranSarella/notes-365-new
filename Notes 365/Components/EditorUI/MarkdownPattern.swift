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
    case italic = #"(?<!\*)\B\*{1}(?!\*)([^*]+)(?<!\*)\*{1}\B(?!\*)"#           // *italic*
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!\*)([^(*|\n)]+)(?<!\*)\*{1}\B(?!\*)(?=(\^| |\n))"#
//    case italic = #"(?<!\*)(?<=(\^| |\n))\*{1}(?!(\*| ))([^(*|\n)]+)(?<!(\*| ))\*{1}\B(?!\*)(?=($| |\n))"#
    case bold = #"(?<!\*)\B\*{2}(?!\*)([^*]+)(?<!\*)\*{2}\B(?!\*)"#             // **bold**
    case boldAndItalic = #"(?<!\*)\B\*{3}(?!\*)([^*]+)(?<!\*)\*{3}\B(?!\*)"#    // **bold and italic**
    case strikethrough = #"~~(.*?)~~"#
    
    case h1 = #"((^#) (.+))"#
    case h2 = #"((^#{2}) (.+))"#
    case h3 = #"((^#{3}) (.+))"#
    case h4 = #"((^#{4}) (.+))"#
    case h5 = #"((^#{5}) (.+))"#
    case h6 = #"((^#{6}) (.+))"#
        
//    case orderedList =  #"^[[:blank:]]*?[0-9]+\.(.*)"#  //#"\n[0-9]+\.(.*)"#
    case orderedList =  #"^[[:blank:]]*?[0-9]+\."#  //#"\n[0-9]+\.(.*)"#
//    case unorderedList = #"^[[:blank:]]*?- ([^\[x \]].*)"# //#"\n\-(.*)"#
    case unorderedList = #"^[[:blank:]]*?- "# //#"\n\-(.*)"#
//    case checkList = #"(^[[:blank:]]?- )\[([ Xx])\] (.*)"#
    case checkList = #"(^[[:blank:]]*?- )\[([ Xx])\] "#
    
    case inlineCode = #"\B`(.*?)`(\B)(?=( |\b|$|\s))"#
    case codeBlock = #"^`{3}([\w]*)\n([\S\s]+?)\n^`{3}$"#
        
    // ^`{3}([\w]*)\n([\S\s]+?)\n`{3}$
    
    case blockQuote = #"^(\>)(.*)"#
//    case blockQuote = #"\n(\>)(.*)"#
    
    case link = #"\[([^\[]+)\]\(([^\)]+)\)"#
    
    case horizontalRule = #"\n-{5,}"#
}


class EditorSettings {
    static let lineSpacing: CGFloat = 10
}
