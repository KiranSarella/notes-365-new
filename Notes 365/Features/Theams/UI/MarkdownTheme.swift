//
//  Theam.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import Foundation
import SwiftUI

struct MarkdownTheme: Identifiable {
    
    var id: UUID
    var themeName: String = "default"
    var appearanceType: AppearanceType = .light
    var fontName: String = "system"
    var fontSize: Float = 16
    var canvasColor: Color = Color.white
    var bodyColor: Color = Color.primary
    var headingColor: Color = Color.primary
    var styleColor: Color = Color.primary
    var highlightColor: Color = Color.primary
    var codeColor: Color = Color.primary
    var blockQuoteColor: Color = Color.primary
    var listColor: Color = Color.primary
    var linkColor: Color = Color.primary
    
    var headingFontName: String = "system"
    var blockQuoteFontName: String = "system"
    
    var enableHeadingFont: Bool = true
    var enableBlockQuoteFont: Bool = true
    var enableBackground: Bool = true
    
    init(id: UUID) {
        self.id = id
    }
    
    var defaultCalvasColor: Color {
        switch appearanceType {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        }
    }
    
    var dynamicCanvasColor: Color {
        enableBackground ? canvasColor : defaultCalvasColor
    }
    
    var dynamicHeadingFont: String {
        enableHeadingFont ? headingFontName : fontName
    }
    
    var dynamicBlockQuoteFont: String {
        enableBlockQuoteFont ? blockQuoteFontName : fontName
    }
}

extension MarkdownTheme: Equatable {
    
}


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

extension Theme {
    var markdownTheme: MarkdownTheme {
        var m = MarkdownTheme(id: id)
        m.themeName = themeName
        m.fontName = fontName
        m.fontSize = fontSize
        m.appearanceType = appearanceType
        m.canvasColor = canvasColor
        m.bodyColor = bodyColor
        m.styleColor = styleColor
        m.codeColor = codeColor
        m.blockQuoteColor = blockQuoteColor
        m.listColor = listColor
        m.headingColor = headingColor
        m.highlightColor = highlightColor
        m.linkColor = linkColor
        
        m.headingFontName = headingFontName
        m.blockQuoteFontName = blockQuoteFontName
        
        m.enableHeadingFont = enableHeadingFont
        m.enableBlockQuoteFont = enableBlockQuoteFont
        m.enableBackground  = enableBackground
        
        return m
    }
}

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}

extension MarkdownTheme {
    var theme: Theme {
        var m = Theme(id: id, themeName: themeName, appearanceType: appearanceType)
        m.fontName = fontName
        m.fontSize = fontSize
        m.canvasColor = canvasColor
        m.bodyColor = bodyColor
        m.styleColor = styleColor
        m.codeColor = codeColor
        m.blockQuoteColor = blockQuoteColor
        m.listColor = listColor
        m.headingColor = headingColor
        m.highlightColor = highlightColor
        m.linkColor = linkColor
        
        m.headingFontName = headingFontName
        m.blockQuoteFontName = blockQuoteFontName
        
        m.enableHeadingFont = enableHeadingFont
        m.enableBlockQuoteFont = enableBlockQuoteFont
        m.enableBackground  = enableBackground
        
        return m
    }
}
