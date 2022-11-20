//
//  FormatOptions.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import Foundation


public enum TextStyleKey {
    
    case bold
    case italic
    case strikethrough
    
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    
    case inline
    case codeBlock
    case blockQuote
    
    case link
    case image
    
    case font
    case fontSizeBigger
    case fontSizeSmaller
    
    case getContent
    
    case editorType
    case clear
    
    case textUpdate
    case theme
    
}


public enum EditorType: String, CaseIterable, Identifiable {
    case smart
    case markdown
    
    public var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .smart: return "Smart"
        case .markdown: return "Markdown"
        }
    }
}
