//
//  PreDefinedThemes.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftUI

class DefaultThemes {
//    static func loadTheams() -> [Theme] {
//        return [generateBasicLightTheme(),
//                generateBasicDarkTheme(),
//                generateCustomizedLightTheme(),
//                generateCustomizedDarkTheme()]
//    }
    
//    static func generateBasicLightTheme() -> Theme {
//        var theme = Theme(id: UUID(), themeName: "Basic", appearanceType: .light)
//        theme.fontName = "Helvetica"
//        theme.fontSize = 16
//        theme.bodyColor = Color.primary
//        theme.styleColor = Color.primary
//        theme.codeColor = Color.primary
//        theme.blockQuoteColor = Color.primary
//        theme.listColor = Color.primary
//        theme.headingColor = Color.primary
//        return theme
//    }
//    
//    static func generateBasicDarkTheme() -> Theme {
//        var theme = Theme(id: UUID(), themeName: "Basic", appearanceType: .dark)
//        theme.fontName = "Helvetica"
//        theme.fontSize = 16
//        theme.bodyColor = Color.primary
//        theme.styleColor = Color.primary
//        theme.codeColor = Color.primary
//        theme.blockQuoteColor = Color.primary
//        theme.listColor = Color.primary
//        theme.headingColor = Color.primary
//        return theme
//    }
//    
    static func generateCustomizedLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 20
        theme.canvasColor = Color.white
        theme.bodyColor = Color.primary
        theme.headingColor = Color.orange
        theme.styleColor = Color.purple
        theme.codeColor = Color.blue
        theme.blockQuoteColor = Color.green
        theme.listColor = Color.mint
        theme.highlightColor = Color.yellow.opacity(0.45)
        
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    static func generateCustomizedDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "ChalkboardSE-Light"
        theme.fontSize = 18
        theme.canvasColor = Color.black
        theme.bodyColor = Color.white
        theme.headingColor = Color.yellow
        theme.styleColor = Color.pink
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.mint
        theme.listColor = Color.red
        theme.highlightColor = Color.purple.opacity(0.25)
        
        theme.headingFontName = "Helvetica"
        theme.blockQuoteFontName = "Helvetica"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
}
