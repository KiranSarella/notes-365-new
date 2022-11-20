//
//  Theam.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Combine


struct MarkdownTheme: Identifiable, Codable {
    
    var id = UUID()
    var themeName: String = "default"
    
    var font: UIFont = UIFont.systemFont(ofSize: 14)
    // body
    var bodyColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // Heading
    var headingColor: NamedColor = NamedColor(colorName: "primary", listName: "dynamic")
    // h1...h6
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
    
    init() { }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        themeName = try container.decode(String.self, forKey: .themeName)
        // body
        font = try container.decode(Data.self, forKey: .font).decodeToFont()
        
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
            return
        }
        
        let decoder = JSONDecoder()
        let obj = try! decoder.decode(MarkdownTheme.self, from: rawValue.data(using: .utf8)!)

        id = obj.id
        themeName = obj.themeName
        // body
        font = obj.font
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
        case font
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
        try container.encode(font.encodeToData(), forKey: .font)
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


extension Color {
   
    /// Explicitly extracted Core Graphics color
    /// for the purpose of reconstruction and persistance.
    var cgColor_: CGColor {
        UIColor(self).cgColor
    }
}

extension UserDefaults {
    func setColor(_ color: Color, forKey key: String) {
        let cgColor = color.cgColor_
        let array = cgColor.components ?? []
        set(array, forKey: key)
    }
    
    func color(forKey key: String) -> Color {
        guard let array = object(forKey: key) as? [CGFloat] else { return .accentColor }
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
        return Color(color)
    }
}

// encode, decode color
extension Color {
    // encode
    func encodeToData() throws -> Data {
        
        let UIColor = UIColor(self)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor, requiringSecureCoding: false)
        
        return colorData
    }
    
}

extension Data {
    // decode color
    func decodeToColor() throws -> Color {
        let bodyColorObj = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: self)
        return Color(bodyColorObj!)
    }
}

// codable font
extension UIFont {
    func encodeToData() throws -> Data {
        let fontData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return fontData
    }
}

extension Data {
    // decode font
    func decodeToFont() throws -> UIFont {
        let fontObj = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIFont.self, from: self)
        return fontObj!
    }
}


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


enum MarkdownHeading: Int, CaseIterable {
    case h1 = 1
    case h2 = 2
    case h3 = 3
    case h4 = 4
    case h5 = 5
    case h6 = 6
    
    var title: String {
        return "Heading \(self.rawValue)"
    }
    
    var fontSize: CGFloat {
        getHeadingFontSize()
    }
    
    var fontSizePercent: CGFloat {
        
        /*
         https://stackoverflow.com/questions/2325850/h1-h6-font-sizes-in-html
         
         h1: 2em
         h2: 1.5em
         h3: 1.17em
         h4: 1em
         h5: 0.83em
         h6: 0.67em
         */
        
        switch self {
        case .h1:
            return 2
        case .h2:
            return 1.5
        case .h3:
            return 1.17
        case .h4:
            return 1
        case .h5:
            return 0.83
        case .h6:
            return 0.67
        }
    }
    
    func getHeadingFontSize(baseFontSize: CGFloat = 14) -> CGFloat {
        
        return self.fontSizePercent * baseFontSize
    }
}



extension MarkdownTheme {
    
    static func getDefaultTheams() -> [MarkdownTheme] {
        return [generateBlackWhiteTheme(), generateColorTheme(), generateCustomized1Theme(), generateCustomized2Theme()]
    }
    
    static func generateBlackWhiteTheme() -> MarkdownTheme {
        var blackWhiteTheme = MarkdownTheme()
        blackWhiteTheme.themeName = "Black&White"
        // leaving all to defaults 
        return blackWhiteTheme
    }
    
    static func generateColorTheme() -> MarkdownTheme {
        
        // apple markdown
        var theme = MarkdownTheme()
        theme.themeName = "Color"
        theme.bodyColor = NamedColor(colorName: "Primary", listName: "Dynamic")
        theme.styleColor = NamedColor(colorName: "purple", listName: "System")
        theme.codeColor = NamedColor(colorName: "blue", listName: "System")
        theme.blockQuoteColor = NamedColor(colorName: "Clover", listName: "Crayons")
        theme.listColor = NamedColor(colorName: "Strawberry", listName: "Crayons")
        
        theme.h1Color = NamedColor(colorName: "Mint", listName: "System")
        theme.h2Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h3Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h4Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h5Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h6Color = NamedColor(colorName: "Cyan", listName: "System")
        
        return theme
    }
    
    static func generateCustomized1Theme() -> MarkdownTheme {
        var theme = MarkdownTheme()
        theme.themeName = "Customized1"
        theme.font = UIFont(name: "Courier New Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        theme.bodyColor = NamedColor(colorName: "Secondary", listName: "Dynamic")
        theme.styleColor = NamedColor(colorName: "purple", listName: "System")
        theme.codeColor = NamedColor(colorName: "blue", listName: "System")
        theme.blockQuoteColor = NamedColor(colorName: "Clover", listName: "Crayons")
        theme.listColor = NamedColor(colorName: "Strawberry", listName: "Crayons")
        
        theme.h1Color = NamedColor(colorName: "Mint", listName: "System")
        theme.h2Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h3Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h4Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h5Color = NamedColor(colorName: "Cyan", listName: "System")
        theme.h6Color = NamedColor(colorName: "Cyan", listName: "System")
        
        return theme
    }
    
    static func generateCustomized2Theme() -> MarkdownTheme {
        // Orchid theme
        var theme = MarkdownTheme()
        theme.themeName = "Customized2"
        theme.font = UIFont(name: "Comic Sans MS", size: 16) ?? UIFont.systemFont(ofSize: 16)
        theme.bodyColor = NamedColor(colorName: "Fern", listName: "Crayons")
        theme.styleColor = NamedColor(colorName: "Green", listName: "System")
        theme.codeColor = NamedColor(colorName: "Fern", listName: "Crayons")
        theme.blockQuoteColor = NamedColor(colorName: "Fern", listName: "Crayons")
        theme.listColor = NamedColor(colorName: "Fern", listName: "Crayons")
        
        theme.headingColor = NamedColor(colorName: "Orange", listName: "System")
        theme.h1Color = NamedColor(colorName: "Orange", listName: "System")
        theme.h2Color = NamedColor(colorName: "Orange", listName: "System")
        theme.h3Color = NamedColor(colorName: "Orange", listName: "System")
        theme.h4Color = NamedColor(colorName: "Orange", listName: "System")
        theme.h5Color = NamedColor(colorName: "Orange", listName: "System")
        theme.h6Color = NamedColor(colorName: "Orange", listName: "System")
        
        return theme
    }
    
   
    
}


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


#endif
