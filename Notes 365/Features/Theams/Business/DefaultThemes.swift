//
//  PreDefinedThemes.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftUI

class DefaultThemes {

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
        
        theme.headingFontName = "Arial Rounded MT Bold"
        theme.blockQuoteFontName = "Kefa"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
    static func generateCustomizedDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "Helvetica Neue"
        theme.fontSize = 22
        theme.canvasColor = Color.black
        theme.bodyColor = Color.white
        theme.headingColor = Color.yellow
        theme.styleColor = Color.pink
        theme.codeColor = Color.green
        theme.blockQuoteColor = Color.mint
        theme.listColor = Color.red
        theme.highlightColor = Color.purple.opacity(0.45)
        
        theme.headingFontName = "Impact"
        theme.blockQuoteFontName = "Futura"
        
        theme.enableBackground = true
        theme.enableHeadingFont = true
        theme.enableBlockQuoteFont = true
        
        return theme
    }
    
}
