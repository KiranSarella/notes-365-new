//
//  ThemeBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import Foundation

class ThemeBusiness {
    
    private let themeVersionKey = "theme_version"
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
            saveLightTheme(id: defaultThemes[0].id.uuidString)
            saveDarkTheme(id: defaultThemes[1].id.uuidString)
            return defaultThemes
        }
    }
    
    func getLightTheme() -> MarkdownTheme {
        
        let themes = getThemes()
        if let id = fetchLightTheme() {
            if let theme = themes.first(where: { $0.id.uuidString == id }) {
                return theme
            }
        }
        // if no saved key exits, return default theme
        return themes[0]
    }
    
    func getDarkTheme() -> MarkdownTheme {
        let themes = getThemes()
        if let id = fetchDarkTheme() {
            if let theme = themes.first(where: { $0.id.uuidString == id }) {
                return theme
            }
        }
        // if no saved key exits, return default theme
        return themes[1]
    }
    
    // MARK: - Persist Themes List
    func getStoredThemes() -> [MarkdownTheme]? {
        if let version = UserDefaults.standard.value(forKey: themeVersionKey) as? Int, version == 2 {
            if let data = UserDefaults.standard.value(forKey: themeManagerKey) as? Data {
                if let obj = try? PropertyListDecoder().decode([MarkdownTheme].self, from: data) {
                    return obj
                }
            }
        } else {
            // old version, so
            // clear old saved themes
            clearSavedThemes()
            // set theme version
            UserDefaults.standard.set(2, forKey: themeVersionKey)
        }
        return nil
    }
    
    func clearSavedThemes() {
        UserDefaults.standard.removeObject(forKey: themeManagerKey)
        UserDefaults.standard.removeObject(forKey: themeLightKey)
        UserDefaults.standard.removeObject(forKey: themeDarkKey)
    }
    
    func saveThemes(themes: [MarkdownTheme]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(themes), forKey: themeManagerKey)
    }
    
    func saveLightTheme(id: String) {
        UserDefaults.standard.set(id, forKey: themeLightKey)
    }
    
    func saveDarkTheme(id: String) {
        UserDefaults.standard.set(id, forKey: themeDarkKey)
    }
    
    private func fetchLightTheme() -> String? {
        if let data = UserDefaults.standard.value(forKey: themeLightKey) as? String {
            return data
        }
        
        return nil
    }
    
    private func fetchDarkTheme() -> String?   {
        if let data = UserDefaults.standard.value(forKey: themeDarkKey) as? String {
            return data
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
        theme.fontName = "Helvetica"
//        theme.fontSize = 16
        theme.bodyColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.styleColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.codeColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.blockQuoteColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.listColor = NamedColor(red: 0, green: 0, blue: 0)
        theme.headingColor = NamedColor(red: 0, green: 0, blue: 0)
        
        return theme
    }
    
    static func generateBasicDarkTheme() -> MarkdownTheme {
        
        // apple markdown
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Basic-dark"
        theme.fontName = "Helvetica"
//        theme.fontSize = 16
        theme.bodyColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.styleColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.codeColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.blockQuoteColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.listColor = NamedColor(red: 1, green: 1, blue: 1)
        theme.headingColor = NamedColor(red: 1, green: 1, blue: 1)
        
        return theme
    }
    
    static func generateCustomizedLightTheme() -> MarkdownTheme {
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized-light"
        theme.fontName = "Noteworthy"
        theme.fontSize = 18
        theme.bodyColor = NamedColor(hex: 0x000000)
        theme.styleColor = NamedColor(hex: 0xbf5af2)
        theme.codeColor = NamedColor(hex: 0x797979)
        theme.blockQuoteColor = NamedColor(hex: 0x009192)
        theme.listColor = NamedColor(hex: 0xff2600)
        theme.headingColor = NamedColor(hex: 0xff9200)
        
        return theme
    }
    
    static func generateCustomizedDarkTheme() -> MarkdownTheme {
        // Orchid theme
        var theme = MarkdownTheme(id: UUID())
        theme.themeName = "Customized-dark"
        theme.fontName = "ChalkboardSE-Light"
        theme.fontSize = 18
        theme.bodyColor = NamedColor(hex: 0xffffff)
        theme.styleColor = NamedColor(hex: 0xffd60a)
        theme.codeColor = NamedColor(hex: 0x0096ff)
        theme.blockQuoteColor = NamedColor(hex: 0x4e8f00)
        theme.listColor = NamedColor(hex: 0xff2f92)
        theme.headingColor = NamedColor(hex: 0xff9f0a)
        
        return theme
    }
    
    
    
}
