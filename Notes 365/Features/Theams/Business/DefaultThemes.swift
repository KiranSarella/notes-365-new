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
    
    static func defaultWhiteTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        
#if targetEnvironment(macCatalyst)
        theme.fontSize = 30
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 24
        } else {
            theme.fontSize = 18
        }
#endif
        
        theme.fontName = "Helvetica"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        theme.codeFontName = "Monaco"
        
        theme.canvasColor = Color.white
        theme.bodyColor = Color.primary
        theme.headingColor = Color(hex: 0xF28D01)
        theme.styleColor = Color(hex: 0x009193)
        theme.highlightColor = Color(hex: 0xFFCC00, opacity: 0.45)
        theme.blockQuoteColor = Color(hex: 0x4F8F00)
        theme.codeColor = Color(hex: 0x0096FF)
        
        return theme
    }
    
    static func skyBlueTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 28
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 22
        } else {
            theme.fontSize = 18
        }
#endif
        
        theme.fontName = "Helvetica Neue"
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Monaco"
        
        theme.canvasColor = Color(hex: 0xE6F7FF)
        theme.bodyColor = Color.primary
        theme.headingColor = Color.orange
        theme.styleColor = Color.purple
        theme.codeColor = Color.blue
        theme.blockQuoteColor = Color.green
        theme.listColor = Color.mint
        theme.highlightColor = Color(hex: 0xffe941, opacity: 0.45)
        
        return theme
    }
    
    static func grayTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        
#if targetEnvironment(macCatalyst)
        theme.fontSize = 34
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 28
        } else {
            theme.fontSize = 22
        }
#endif
        theme.fontName = "Times New Roman"
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Proxima Nova"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0xF5F5F5)
        theme.bodyColor = Color(hex: 0x333333)
        theme.headingColor = Color(hex: 0x0160A8)
        theme.styleColor = Color(hex: 0xC01D04)
        theme.highlightColor = Color(hex: 0xFFD479, opacity: 0.6)
        theme.blockQuoteColor = Color(hex: 0x009051)
        theme.codeColor = Color(hex: 0x5E5E5E)
        
        return theme
    }
    
    static func lightYellowTheme() -> Theme {
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
        theme.fontName = "Gill Sans"
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Avenir"
        theme.codeFontName = "PT Mono"
        
        theme.canvasColor = Color(hex: 0xFFD479, opacity: 0.5)
        theme.bodyColor = Color(hex: 0x5E5E5E)
        theme.headingColor = Color(hex: 0x4C50A0)
        theme.styleColor = Color(hex: 0xBA659D)
        theme.highlightColor = Color(hex: 0xAF52DE, opacity: 0.2)
        theme.blockQuoteColor = Color(hex: 0x058081)
        theme.codeColor = Color(hex: 0x008249)
        
        return theme
    }
    
    static func beigeTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 34
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 26
        } else {
            theme.fontSize = 22
        }
#endif
        theme.fontName = "Avenir Next"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "PT Mono"
        
        theme.canvasColor = Color(hex: 0xFAF3E0)
        theme.bodyColor = Color(hex: 0x663300)
        theme.headingColor = Color(hex: 0x663300)
        theme.styleColor = Color(hex: 0x006400)
        theme.highlightColor = Color(hex: 0x8EEEF1, opacity: 0.50)
        theme.blockQuoteColor = Color(hex: 0x941751)
        theme.codeColor = Color(hex: 0x005493)
        
        
        return theme
    }
    
}

extension DefaultThemes {
    
    // MARK: - Dark Themes
    static func defaultDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 30
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 24
        } else {
            theme.fontSize = 20
        }
#endif
        theme.fontName = "Helvetica Neue"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Menlo"
        
        theme.canvasColor = Color.black
        theme.bodyColor = Color.white
        theme.headingColor = Color.yellow
        theme.styleColor = Color.pink
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.mint
        theme.listColor = Color.red
        theme.highlightColor = Color.purple.opacity(0.55)
        
        return theme
    }
    
    static func darkGaryYellowTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 28
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 22
        } else {
            theme.fontSize = 18
        }
#endif
        theme.fontName = "Avenir"
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Gill Sans"
        theme.codeFontName = "PT Mono"
        
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
    
    static func generateGoldCharcoalTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 32
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 24
        } else {
            theme.fontSize = 20
        }
#endif
        theme.fontName = "Futura"
        theme.headingFontName = "Georgia"
        theme.blockQuoteFontName = "Gelvji"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0x1B2627)
        theme.bodyColor = Color(hex: 0xE0AF62)
        theme.headingColor = Color(hex: 0xFFD97B)
        theme.styleColor = Color(hex: 0xEFD700)
        theme.highlightColor = Color(hex: 0xFF7E79, opacity: 0.45)
        theme.blockQuoteColor = Color(hex: 0xDB5C5B)
        theme.codeColor = Color(hex: 0x68BDE2)
        
        
        
        return theme
    }
    
    
    
    static func GrayDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 30
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 22
        } else {
            theme.fontSize = 20
        }
#endif
        theme.fontName = "Verdana"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0x292A2F)
        theme.bodyColor = Color(hex: 0xD6D6D6)
        theme.headingColor = Color(hex: 0xFF6F61)
        theme.styleColor = Color(hex: 0x00A55D)
        theme.highlightColor = Color(hex: 0x76D6FF, opacity: 0.35)
        theme.blockQuoteColor = Color(hex: 0x67B7A4)
        theme.codeColor = Color(hex: 0xFFFC79)
        
        return theme
    }
    
    
    static func DarkBlueTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
#if targetEnvironment(macCatalyst)
        theme.fontSize = 30
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            theme.fontSize = 22
        } else {
            theme.fontSize = 20
        }
#endif
        theme.fontName = "Courier Prime"
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Futura"
        theme.codeFontName = "Courier New"
        
        theme.canvasColor = Color(hex: 0x002456)
        theme.bodyColor = Color(hex: 0xFFFFFF)
        theme.headingColor = Color(hex: 0xFFFB00)
        theme.styleColor = Color(hex: 0x00F900)
        theme.highlightColor = Color(hex: 0x76D6FF, opacity: 0.35)
        theme.blockQuoteColor = Color(hex: 0x67B7A4)
        theme.codeColor = Color(hex: 0xFF1400)
        
        return theme
    }
}
