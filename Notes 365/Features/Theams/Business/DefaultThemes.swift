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
    
    static func generateGrayTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        
#if targetEnvironment(macCatalyst)
        theme.fontSize = 32
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 28
        } else {
            theme.fontSize = 22
        }
#endif
        theme.fontName = "Avenir"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Proxima Nova"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0xF5F5F5)
        theme.bodyColor = Color(hex: 0x333333)
        theme.headingColor = Color(hex: 0x000000)
        theme.styleColor = Color(hex: 0xC91E03)
        theme.highlightColor = Color(hex: 0xFFD479, opacity: 0.6)
        theme.blockQuoteColor = Color(hex: 0x009051)
        theme.codeColor = Color(hex: 0x0433FF)
        
        return theme
    }
    
    static func generateBlueTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 32
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color(hex: 0xE6F7FF)
        theme.bodyColor = Color(hex: 0x0000FF)
        theme.headingColor = Color(hex: 0x0000FF)
        theme.styleColor = Color(hex: 0x0000FF)
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        
        return theme
    }
    
    static func generateGreenTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 32
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color(hex: 0xE6FFE6)
        theme.bodyColor = Color(hex: 0x006600)
        theme.headingColor = Color(hex: 0x006600)
        theme.styleColor = Color(hex: 0x006600)
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        
        return theme
    }
    
    static func generateBeigeTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 34
        
        theme.fontName = "Avenir Next"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color(hex: 0xFAF3E0)
        theme.bodyColor = Color(hex: 0x663300)
        theme.headingColor = Color(hex: 0x663300)
        theme.styleColor = Color(hex: 0x663300)
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color(hex: 0x941751)
        
        return theme
    }
    
    
    static func generateLavenderTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 32
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color(hex: 0xE6E6FA)
        theme.bodyColor = Color(hex: 0x660099)
        theme.headingColor = Color(hex: 0x660099)
        theme.styleColor = Color(hex: 0x660099)
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        
        return theme
    }
    
    
    
    
    static func generateCustomizedLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 24
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Kefa"
        theme.codeFontName = "Monaco"
        
        theme.canvasColor = Color(hex: 0xE6F7FF)
        theme.bodyColor = Color.primary
        theme.headingColor = Color.orange
        theme.styleColor = Color.purple
        theme.codeColor = Color.blue
        theme.blockQuoteColor = Color.green
        theme.listColor = Color.mint
        theme.highlightColor = Color.yellow.opacity(0.45)
        
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
        theme.codeFontName = "Courier New"
        
        return theme
    }
    
    static func lightPurpleLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontSize = 32
        
        theme.fontName = "Times New Roman"
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Verdana"
        theme.codeFontName = "Andale Mono"
        
        theme.canvasColor = Color(hex: 0xAAA7CC, opacity: 0.16)
        theme.bodyColor = Color(hex: 0x000000)
        theme.headingColor = Color(hex: 0xFF4E00)
        theme.styleColor = Color(hex: 0x17AF4C)
        theme.codeColor = Color(hex: 0x046AFF)
        theme.blockQuoteColor = Color(hex: 0x009B93)
        theme.listColor = Color(hex: 0x941751)
        theme.highlightColor = Color(hex: 0xFFD479, opacity: 0.50)
        
        return theme
    }
    
}

extension DefaultThemes {
    
    // MARK: - Dark Themes
    static func generateBasicDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontSize = 32
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color.black
        theme.bodyColor = Color.white
        theme.headingColor = Color.white
        theme.styleColor = Color.white
        theme.codeColor = Color.white
        theme.blockQuoteColor = Color.white
        
        return theme
    }
    
    static func generateGoldCharcoalTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontSize = 32
        
//        theme.fontName = "Gyneric BRK"
        theme.fontName = "Verdana"
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Gelvji"
        theme.codeFontName = "PT Mono"
        
        theme.canvasColor = Color(hex: 0x1B2627)
        theme.bodyColor = Color(hex: 0xE0AF62)
        theme.headingColor = Color(hex: 0x00C3DA)
        theme.styleColor = Color(hex: 0xFFFB00)
        theme.codeColor = Color(hex: 0x6CB36B)
        theme.blockQuoteColor = Color(hex: 0xDB5C5B)
        theme.highlightColor = Color(hex: 0x00DBFB, opacity: 0.40)
        
        return theme
    }
    
    
    
    static func generateCustomizedDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontSize = 24
        
        theme.fontName = "Helvetica Neue"
        theme.headingFontName = "Impact"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color(hex: 0x28292A, opacity: 1)
        theme.bodyColor = Color.white
        theme.headingColor = Color.yellow
        theme.styleColor = Color.pink
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.mint
        theme.listColor = Color.red
        theme.highlightColor = Color.purple.opacity(0.45)
        
        return theme
    }
    
    static func GrayDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontSize = 30
        
        theme.fontName = "Avenir"
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Verdana"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0x292A2F)
        theme.bodyColor = Color(hex: 0xFFFFFF)
        theme.headingColor = Color(hex: 0xFC6A5D)
        theme.styleColor = Color(hex: 0xFC5FA3)
        theme.codeColor = Color(hex: 0xB4B300)
        theme.blockQuoteColor = Color(hex: 0x67B7A4)
        theme.listColor = Color(hex: 0x5BC67D)
        theme.highlightColor = Color(hex: 0x73FCD6, opacity: 0.38)
        
        return theme
    }
    
    
    
}
