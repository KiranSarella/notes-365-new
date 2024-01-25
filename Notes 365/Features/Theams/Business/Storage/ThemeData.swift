//
//  ThemeData.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftData
import SwiftUI


struct ColorData {
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
    var opacity: Double = 1
    
    init(color: Color) {
        let components = color.components
        red = components.red
        green = components.green
        blue = components.blue
        opacity = components.opacity
    }
}

extension ColorData {
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension ColorData: Codable, Hashable { }

extension ColorData: CustomStringConvertible {
    var description: String {
        "\(red) \(green) \(blue) \(opacity)"
    }
}

//@Model
class ThemeData: Codable {
    var id: UUID = UUID()
    var themeName: String = "default"
    var appearanceType: String = AppearanceType.light.rawValue
    var fontName: String = "system"
    var fontSize: Float = 16
    // body
    var canvasColor: ColorData = ColorData(color: Color.white)
    var bodyColor: ColorData = ColorData(color: Color.primary)
    // Heading
    var headingColor: ColorData = ColorData(color: Color.primary)
    // bold, italic, strikethrough
    var styleColor: ColorData = ColorData(color: Color.primary)
    var highlightColor: ColorData = ColorData(color: Color.primary)
    // inline code, code block
    var codeColor: ColorData = ColorData(color: Color.primary)
    var blockQuoteColor: ColorData = ColorData(color: Color.primary)
    var listColor: ColorData = ColorData(color: Color.primary)
    var linkColor: ColorData = ColorData(color: Color.primary)
    // other fonts
    var headingFontName: String = "system"
    var blockQuoteFontName: String = "system"
    
    var enableHeadingFont: Bool = true
    var enableBlockQuoteFont: Bool = true
    var enableBackground: Bool = true
    
    init() {
        
    }
}

extension ThemeData: CustomStringConvertible {
    var description: String {
        var str = ""
        str.append("\(themeName)\n")
        str.append("\(id.uuidString)\n")
        str.append("\(appearanceType)\n")
        str.append("\(fontName)\n")
        str.append("\(fontSize)\n")
        str.append("\(headingFontName)\n")
        str.append("\(blockQuoteFontName)\n")
        return str
    }
}

extension ThemeData {
    func sync(newData: ThemeData) {
        themeName = newData.themeName
        appearanceType = newData.appearanceType
        fontName = newData.fontName
        fontSize = newData.fontSize
        canvasColor = newData.canvasColor
        bodyColor = newData.bodyColor
        headingColor = newData.headingColor
        styleColor = newData.styleColor
        highlightColor = newData.highlightColor
        codeColor = newData.codeColor
        blockQuoteColor = newData.blockQuoteColor
        listColor = newData.listColor
        linkColor = newData.linkColor
        
        headingFontName = newData.headingFontName
        blockQuoteFontName = newData.blockQuoteFontName
        
        enableBackground = newData.enableBackground
        enableHeadingFont = newData.enableHeadingFont
        enableBlockQuoteFont = newData.enableBlockQuoteFont
    }
}

