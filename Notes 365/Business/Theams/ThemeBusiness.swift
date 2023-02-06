//
//  ThemeBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import Foundation
//import AppKit

class ThemeBusiness {
    
    private let themeManagerKey = "theme_manager_ud"
    private let themeLightKey = "theme_light"
    private let themeDarkKey = "theme_dark"
    
    
    /*
     step 1:
     get any already stored themes and selected theme from storage
     otherwise
     configure default themes and select default theme.
     
     
     */
    
    func getThemes() -> [MarkdownTheme] {
        
        if let themes = getStoredThemes() {
            return themes
        } else {
            let defaultThemes = ThemeBusiness.getDefaultTheams()
            saveThemes(themes: defaultThemes)
            return defaultThemes
        }
    }
    
    func getLightTheme() -> MarkdownTheme {
        return fetchLightTheme() ?? getThemes().first!
    }
    
    func getDarkTheme() -> MarkdownTheme {
        return fetchDarkTheme() ?? getThemes().first!
    }
    
    // MARK: - Persist Themes List
    func getStoredThemes() -> [MarkdownTheme]? {
        if let data = UserDefaults.standard.value(forKey: themeManagerKey) as? Data {
            if let obj = try? PropertyListDecoder().decode([MarkdownTheme].self, from: data) {
                return obj
            }
        }
        
        return nil
    }
    
//    func clearSavedThemes() {
//        UserDefaults.standard.removeObject(forKey: themeManagerKey)
//    }
    
    func saveThemes(themes: [MarkdownTheme]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(themes), forKey: themeManagerKey)
    }
    
    func saveLightTheme(theme: MarkdownTheme) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(theme), forKey: themeLightKey)
    }
    
    func saveDarkTheme(theme: MarkdownTheme) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(theme), forKey: themeDarkKey)
    }
    
    func fetchLightTheme() -> MarkdownTheme? {
        if let data = UserDefaults.standard.value(forKey: themeLightKey) as? Data {
            if let obj = try? PropertyListDecoder().decode(MarkdownTheme.self, from: data) {
                return obj
            }
        }
        
        return nil
    }
    
    func fetchDarkTheme() -> MarkdownTheme?   {
        if let data = UserDefaults.standard.value(forKey: themeDarkKey) as? Data {
            if let obj = try? PropertyListDecoder().decode(MarkdownTheme.self, from: data) {
                return obj
            }
        }
        
        return nil
    }
    
}

extension ThemeBusiness {
    
    static func getDefaultTheams() -> [MarkdownTheme] {
        return [generateBlackWhiteTheme(), generateColorTheme(), generateCustomized1Theme(), generateCustomized2Theme()]
    }
    
    static func generateBlackWhiteTheme() -> MarkdownTheme {
        var blackWhiteTheme = MarkdownTheme(id: UUID())
        blackWhiteTheme.themeName = "Basic"
        // leaving all to defaults
        return blackWhiteTheme
    }
    
    static func generateColorTheme() -> MarkdownTheme {
        
        // apple markdown
        var theme = MarkdownTheme(id: UUID())
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
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized1"
        theme.fontName = "Courier New Bold"
        theme.fontSize = 16
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
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized2"
        theme.fontName = "Comic Sans MS"
        theme.fontSize = 16
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
