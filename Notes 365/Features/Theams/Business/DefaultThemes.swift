//
//  PreDefinedThemes.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftUI

class DefaultThemes {
    
    // MARK: - Light Themes
    
    static func generateCustomizedLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 24
        theme.canvasColor = Color(hex: 0x76D6FF, opacity: 0.15)
        theme.bodyColor = Color.primary
        theme.headingColor = Color.orange
        theme.styleColor = Color.purple
        theme.codeColor = Color.blue
        theme.blockQuoteColor = Color.green
        theme.listColor = Color.mint
        theme.highlightColor = Color.yellow.opacity(0.45)
        
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Kefa"
        
        theme.enableBackground = false
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    
    
    
    static func ashLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Cute Aurora"
        theme.fontSize = 30
        theme.canvasColor = Color(hex: 0xF6F1EC)
        theme.bodyColor = Color(hex: 0x212121)
        theme.headingColor = Color(hex: 0x76D6FF)
        theme.styleColor = Color(hex: 0xF60036)
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.cyan
        theme.listColor = Color(hex: 0x4F8F00)
        theme.highlightColor = Color(hex: 0xAF52DE, opacity: 0.45)
        
        theme.headingFontName = "Impact"
        theme.blockQuoteFontName = "Futura"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    static func lightPurpleLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Times New Roman"
        theme.fontSize = 28
        theme.canvasColor = Color(hex: 0xAAA7CC, opacity: 0.40)
        theme.bodyColor = Color(hex: 0x212121)
        theme.headingColor = Color(hex: 0xFC4204)
        theme.styleColor = Color(hex: 0x008F00)
        theme.codeColor = Color(hex: 0x945200)
        theme.blockQuoteColor = Color(hex: 0x009193)
        theme.listColor = Color(hex: 0x941751)
        theme.highlightColor = Color(hex: 0xFFD479, opacity: 0.50)
        
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Verdana"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
}

extension DefaultThemes {
    
    // MARK: - Dark Themes
    
    static func generateCustomizedDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "Helvetica Neue"
        theme.fontSize = 24
        theme.canvasColor = Color(hex: 0x28292A, opacity: 1)
        theme.bodyColor = Color.white
        theme.headingColor = Color.yellow
        theme.styleColor = Color.pink
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.mint
        theme.listColor = Color.red
        theme.highlightColor = Color.purple.opacity(0.45)
        
        theme.headingFontName = "Impact"
        theme.blockQuoteFontName = "Futura"
        
        theme.enableBackground = false
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    static func purpleDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "Cute Aurora"
        theme.fontSize = 30
        theme.canvasColor = Color(hex: 0x372039)
        theme.bodyColor = Color(hex: 0xFFE600)
        theme.headingColor = Color(hex: 0xFF7E79)
        theme.styleColor = Color(hex: 0xF60036)
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.cyan
        theme.listColor = Color(hex: 0x4F8F00)
        theme.highlightColor = Color(hex: 0xAF52DE, opacity: 0.45)
        
        theme.headingFontName = "Impact"
        theme.blockQuoteFontName = "Futura"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
}
