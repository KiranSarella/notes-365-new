//
//  PreDefinedThemes.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftUI

class DefaultThemes {
    static func loadTheams() -> [Theme] {
        return [generateBasicLightTheme(),
                generateBasicDarkTheme(),
                generateCustomizedLightTheme(),
                generateCustomizedDarkTheme()]
    }
    
    static func generateBasicLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Basic", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 16
        theme.bodyColor = Color.primary
        theme.styleColor = Color.primary
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        theme.listColor = Color.primary
        theme.headingColor = Color.primary
        return theme
    }
    
    static func generateBasicDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Basic", appearanceType: .dark)
        theme.fontName = "Helvetica"
        theme.fontSize = 16
        theme.bodyColor = Color.primary
        theme.styleColor = Color.primary
        theme.codeColor = Color.primary
        theme.blockQuoteColor = Color.primary
        theme.listColor = Color.primary
        theme.headingColor = Color.primary
        return theme
    }
    
    static func generateCustomizedLightTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .light)
        theme.fontName = "Helvetica"
        theme.fontSize = 16
        theme.bodyColor = Color.primary
        theme.styleColor = Color.yellow
        theme.codeColor = Color.blue
        theme.blockQuoteColor = Color.green
        theme.listColor = Color.mint
        theme.headingColor = Color.orange
        return theme
    }
    
    static func generateCustomizedDarkTheme() -> Theme {
        var theme = Theme(id: UUID(), themeName: "Color", appearanceType: .dark)
        theme.fontName = "ChalkboardSE-Light"
        theme.fontSize = 16
        theme.bodyColor = Color.white
        theme.styleColor = Color.purple
        theme.codeColor = Color.mint
        theme.blockQuoteColor = Color.yellow
        theme.listColor = Color.red
        theme.headingColor = Color.green
        return theme
    }
    
}
