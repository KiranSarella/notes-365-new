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
        return [generateBasicLightTheme(),
                generateBasicDarkTheme(),
                generateCustomizedLightTheme(),
                generateCustomizedDarkTheme()]
    }
    
    static func generateBasicLightTheme() -> MarkdownTheme {
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Basic-light"
//        theme.fontSize = 16
        theme.bodyColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.styleColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.codeColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.blockQuoteColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.listColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.headingColor = NamedColor(red: 1, green: 1, blue: 1)
        return theme
    }
    
    static func generateBasicDarkTheme() -> MarkdownTheme {
        
        // apple markdown
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Basic-dark"
//        theme.fontSize = 16
        theme.bodyColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.styleColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.codeColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.blockQuoteColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.listColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.headingColor = NamedColor(red: 0, green: 0, blue: 0)
        
        return theme
    }
    
    static func generateCustomizedLightTheme() -> MarkdownTheme {
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized-light"
        theme.fontName = "Courier New Bold"
        theme.fontSize = 16
        theme.bodyColor = NamedColor(hex: 0x000000)
        theme.styleColor = NamedColor(hex: 0xbf5af2)
        theme.codeColor = NamedColor(hex: 0xc0c0c0)
        theme.blockQuoteColor = NamedColor(hex: 0x009192)
        theme.listColor = NamedColor(hex: 0x941651)
        theme.headingColor = NamedColor(hex: 0x0096ff)
        
        return theme
    }
    
    static func generateCustomizedDarkTheme() -> MarkdownTheme {
        // Orchid theme
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized-dark"
        theme.fontName = "Comic Sans MS"
        theme.fontSize = 16
        theme.bodyColor = NamedColor(hex: 0xffffff)
        theme.styleColor = NamedColor(hex: 0xffd60a)
        theme.codeColor = NamedColor(hex: 0x0096ff)
        theme.blockQuoteColor = NamedColor(hex: 0x4e8f00)
        theme.listColor = NamedColor(hex: 0xff2f92)
        theme.headingColor = NamedColor(hex: 0xff9f0a)
        
        return theme
    }
    
    
    
}
