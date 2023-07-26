//
//  Theam.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import Foundation
import SwiftUI

@Observable
struct MarkdownTheme: Identifiable, Hashable, Codable {
    
    var id: UUID = UUID()
    var themeName: String = "default"
    
    var fontName: String = "system"
    var fontSize: Int = 14
    // body
    var bodyColor: NamedColor = NamedColor(hex: 0xffffff)
    // Heading
    var headingColor: NamedColor = NamedColor(hex: 0xffffff)
    // bold, italic, strikethrough
    var styleColor: NamedColor = NamedColor(hex: 0xffffff)
    // inline code, code block
    var codeColor: NamedColor = NamedColor(hex: 0xffffff)
    var blockQuoteColor: NamedColor = NamedColor(hex: 0xffffff)
    var listColor: NamedColor = NamedColor(hex: 0xffffff)
    var linkColor: NamedColor = NamedColor(hex: 0xffffff)
    
    // reset with body font and color option
    
    init(id: UUID) {
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        themeName = try container.decode(String.self, forKey: .themeName)
        // body
        fontName = try container.decode(String.self, forKey: .fontName)
        fontSize = try container.decode(Int.self, forKey: .fontSize)
        
        bodyColor = try container.decode(NamedColor.self, forKey: .bodyColor)
        
        // heading
        headingColor = try container.decode(NamedColor.self, forKey: .headingColor)
        // bold, italic, strikethrough
        styleColor = try container.decode(NamedColor.self, forKey: .styleColor)
        // code
        codeColor = try container.decode(NamedColor.self, forKey: .codeColor)
        blockQuoteColor = try container.decode(NamedColor.self, forKey: .blockQuoteColor)
        listColor = try container.decode(NamedColor.self, forKey: .listColor)
        linkColor = try container.decode(NamedColor.self, forKey: .linkColor)
    }
    
    init?(rawValue: String) {
        
        if rawValue.isEmpty {
            id = UUID()
            return
        }
        
        let decoder = JSONDecoder()
        let obj = try! decoder.decode(MarkdownTheme.self, from: rawValue.data(using: .utf8)!)

        id = obj.id
        themeName = obj.themeName
        // body
        fontName = obj.fontName
        fontSize = obj.fontSize
        bodyColor =  obj.bodyColor
        // heading
        headingColor = obj.headingColor
        // bold
        styleColor = obj.styleColor
        // code
        codeColor = obj.codeColor
        blockQuoteColor = obj.blockQuoteColor
        listColor = obj.listColor
        linkColor = obj.linkColor
    }
    
    
    
}

extension MarkdownTheme: Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MarkdownTheme, rhs: MarkdownTheme) -> Bool {
        lhs.id == rhs.id
    }
}

extension MarkdownTheme  {
    
    enum CodingKeys: CodingKey {
        case id, themeName
        case fontName
        case fontSize
        case bodyColor
        case headingColor
        case styleColor
        case codeColor
        case blockQuoteColor
        case listColor
        case linkColor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(themeName, forKey: .themeName)
        // body
        try container.encode(fontName, forKey: .fontName)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(bodyColor, forKey: .bodyColor)
        // heading
        try container.encode(headingColor, forKey: .headingColor)
        // bold, italic, strikethrough
        try container.encode(styleColor, forKey: .styleColor)
        // code
        try container.encode(codeColor, forKey: .codeColor)
        try container.encode(blockQuoteColor, forKey: .blockQuoteColor)
        try container.encode(listColor, forKey: .listColor)
        try container.encode(linkColor, forKey: .linkColor)
    }
}

import UIKit
extension MarkdownTheme {
    var font: UIFont {
        
//        return UIFont.systemFont(ofSize: CGFloat(self.fontSize))
//        return UIFont.preferredFont(forTextStyle: .body)
//        return UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current)
        
        if self.fontName == "system" {
            return UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        } else {
            return UIFont(name: self.fontName, size: CGFloat(self.fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        }
    }
    
    var font2 : Font {
        Font(font)
    }
}

//extension MarkdownTheme {
//    
//    mutating func reset(with theme: MarkdownTheme) {
//        
//        self.fontName = theme.fontName
//        self.fontSize = theme.fontSize
//        self.bodyColor = theme.bodyColor
//        self.styleColor = theme.styleColor
//        self.codeColor = theme.codeColor
//        self.blockQuoteColor = theme.blockQuoteColor
//        self.listColor = theme.listColor
//        self.headingColor = theme.headingColor
//    }
//}
