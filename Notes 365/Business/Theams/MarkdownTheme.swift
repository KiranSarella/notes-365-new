//
//  Theam.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import Foundation


struct MarkdownTheme: Identifiable, Hashable, Codable {
    
    var id: UUID
    var themeName: String = "default"
    
    var fontName: String = "system"
    var fontSize: Float = 14
    // body
    var bodyColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // Heading
    var headingColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // h1...h6
    var hColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h1Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h2Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h3Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h4Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h5Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var h6Color: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // bold, italic, strikethrough
    var styleColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // inline code, code block
    var codeColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var blockQuoteColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var listColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    var linkColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    
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
        fontSize = try container.decode(Float.self, forKey: .fontSize)
        
        bodyColor = try container.decode(NamedColor.self, forKey: .bodyColor)
        
        // heading
        headingColor = try container.decode(NamedColor.self, forKey: .headingColor)
        // h1...h6
        h1Color = try container.decode(NamedColor.self, forKey: .h1Color)
        h2Color = try container.decode(NamedColor.self, forKey: .h2Color)
        h3Color = try container.decode(NamedColor.self, forKey: .h3Color)
        h4Color = try container.decode(NamedColor.self, forKey: .h4Color)
        h5Color = try container.decode(NamedColor.self, forKey: .h5Color)
        h6Color = try container.decode(NamedColor.self, forKey: .h6Color)
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
        // h1...h6
        h1Color = obj.h1Color
        h2Color = obj.h2Color
        h3Color = obj.h3Color
        h4Color = obj.h4Color
        h5Color = obj.h5Color
        h6Color = obj.h6Color
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
    
}

extension MarkdownTheme  {
    
    enum CodingKeys: CodingKey {
        case id, themeName
        case fontName
        case fontSize
        case bodyColor
        case headingColor
        case h1Color, h2Color, h3Color, h4Color, h5Color, h6Color
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
//        try container.encode(headingFontName, forKey: .headingFontName)
        try container.encode(headingColor, forKey: .headingColor)
        // h1...h6
        try container.encode(h1Color, forKey: .h1Color)
        try container.encode(h2Color, forKey: .h2Color)
        try container.encode(h3Color, forKey: .h3Color)
        try container.encode(h4Color, forKey: .h4Color)
        try container.encode(h5Color, forKey: .h5Color)
        try container.encode(h6Color, forKey: .h6Color)
        // bold, italic, strikethrough
        try container.encode(styleColor, forKey: .styleColor)
        // code
        try container.encode(codeColor, forKey: .codeColor)
        try container.encode(blockQuoteColor, forKey: .blockQuoteColor)
        try container.encode(listColor, forKey: .listColor)
        try container.encode(linkColor, forKey: .linkColor)
    }
}

#if os(macOS)
import AppKit
extension MarkdownTheme {
    
    var font: NSFont {
        if self.fontName == "system" {
            return NSFont.systemFont(ofSize: CGFloat(self.fontSize))
        } else {
            return NSFont(name: self.fontName, size: CGFloat(self.fontSize)) ?? NSFont.systemFont(ofSize: CGFloat(self.fontSize))
        }
    }
}
#endif

#if os(iOS)
import UIKit
extension MarkdownTheme {
    var font: UIFont {
        if self.fontName == "system" {
            return UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        } else {
            return UIFont(name: self.fontName, size: CGFloat(self.fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        }
    }
}
#endif

//extension Color {
//
//    /// Explicitly extracted Core Graphics color
//    /// for the purpose of reconstruction and persistance.
//    var cgColor_: CGColor {
//        NSColor(self).cgColor
//    }
//}
//
//extension UserDefaults {
//    func setColor(_ color: Color, forKey key: String) {
//        let cgColor = color.cgColor_
//        let array = cgColor.components ?? []
//        set(array, forKey: key)
//    }
//
//    func color(forKey key: String) -> Color {
//        guard let array = object(forKey: key) as? [CGFloat] else { return .accentColor }
//        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
//        return Color(color)
//    }
//}
//
//// encode, decode color
//extension Color {
//    // encode
//    func encodeToData() throws -> Data {
//
//        let nscolor = NSColor(self)
//        let colorData = try NSKeyedArchiver.archivedData(withRootObject: nscolor, requiringSecureCoding: false)
//
//        return colorData
//    }
//
//}
//
//extension Data {
//    // decode color
//    func decodeToColor() throws -> Color {
//        let bodyColorObj = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: self)
//        return Color(bodyColorObj!)
//    }
//}
//
//// codable font
//extension NSFont {
//    func encodeToData() throws -> Data {
//        let fontData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
//        return fontData
//    }
//}
//
//extension Data {
//    // decode font
//    func decodeToFont() throws -> NSFont {
//        let fontObj = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSFont.self, from: self)
//        return fontObj!
//    }
//}
//

//extension MarkdownTheme: RawRepresentable {
//    var rawValue: String {
//        get {
//
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//
//            let data = try! encoder.encode(self)
//            let str = String(data: data, encoding: .utf8)!
//
//            return str
//        }
//    }
//}



//extension MarkdownTheme {
//
//    func getCloned() -> MarkdownTheme {
//
//        return MarkdownTheme(rawValue: self.rawValue)!
//    }
//
//}

//extension MarkdownTheme: NSCopying {
//
//    func copy(with zone: NSZone? = nil) -> Any {
//
//
//
//        let theCopy=self.dynamicType.init(a: self.a)
//        theCopy.b = self.b?.copy() as? NSString
//        return theCopy
//    }
//
//}


