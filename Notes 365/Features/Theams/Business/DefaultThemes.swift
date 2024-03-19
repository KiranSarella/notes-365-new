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
    
    static func generateBasicLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 24
        theme.canvasColor = Color.white
        theme.bodyColor = Color.primary
        theme.headingColor = Color.primary
        theme.styleColor = Color.primary
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        theme.listColor = Color.primary
        theme.highlightColor = Color.yellow.opacity(0.25)
        
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        
        theme.enableBackground = false
        theme.enableHeadingFont = false
        theme.enableBlockQuoteFont = false
        
        return theme
    }
    
    static func generateCustomizedLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 24
        theme.canvasColor = Color(hex: 0xE6F7FF)
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
        theme.fontName = "Avenir"
        theme.fontSize = 30
        theme.canvasColor = Color(hex: 0xF6F1EC)
        theme.bodyColor = Color(hex: 0x212121)
        theme.headingColor = Color(hex: 0x0069B8)
        theme.styleColor = Color(hex: 0xE87EC4)
        theme.codeColor = Color(hex: 0x00A75E)
        theme.blockQuoteColor = Color(hex: 0x0096FF)
        theme.listColor = Color(hex: 0xFF2F92)
        theme.highlightColor = Color(hex: 0xAF52DE, opacity: 0.30)
        
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Futura"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    static func lightPurpleLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Times New Roman"
        theme.fontSize = 32
        theme.canvasColor = Color(hex: 0xAAA7CC, opacity: 0.16)
        theme.bodyColor = Color(hex: 0x000000)
        theme.headingColor = Color(hex: 0xFF4E00)
        theme.styleColor = Color(hex: 0x17AF4C)
        theme.codeColor = Color(hex: 0x046AFF)
        theme.blockQuoteColor = Color(hex: 0x009B93)
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
    static func generateBasicDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "Helvetica"
        theme.fontSize = 24
        theme.canvasColor = Color.black
        theme.bodyColor = Color.white
        theme.headingColor = Color.white
        theme.styleColor = Color.white
        theme.codeColor = Color.white
        theme.blockQuoteColor = Color.white
        theme.listColor = Color.white
        theme.highlightColor = Color.yellow.opacity(0.45)
        
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        
        theme.enableBackground = false
        theme.enableHeadingFont = false
        theme.enableBlockQuoteFont = false
        
        return theme
    }
    
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
    
    static func GrayDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "Avenir"
        theme.fontSize = 30
        theme.canvasColor = Color(hex: 0x292A2F)
        theme.bodyColor = Color(hex: 0xFFFFFF)
        theme.headingColor = Color(hex: 0xFC6A5D)
        theme.styleColor = Color(hex: 0xFC5FA3)
        theme.codeColor = Color(hex: 0xB4B300)
        theme.blockQuoteColor = Color(hex: 0x67B7A4)
        theme.listColor = Color(hex: 0x5BC67D)
        theme.highlightColor = Color(hex: 0x73FCD6, opacity: 0.38)
        
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Verdana"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    
    
}
