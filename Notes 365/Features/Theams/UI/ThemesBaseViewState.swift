//
//  ThemesBaseViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 29/03/24.
//

import Foundation

@Observable
class ThemesBaseViewState {
    let business = BusinessFactory.themeInteractor()
 
    var themes = [ThemeVS]()
    var lightThemes = [ThemeVS]()
    var darkThemes = [ThemeVS]()
    
    init() {
        loadLightThemes()
        loadDarkThemes()
    }
    
    func setLightThemes() {
        themes = lightThemes
    }
    
    func setDarkThemes() {
        themes = darkThemes
    }
    
    func loadLightThemes() {
        lightThemes.removeAll()
        
        let defaultsThemesList = business.getDefaultLightThemes()
        let defaultThemes = defaultsThemesList.map { theme in
            var t = theme.markdownTheme
            t.isCustomTheme = false
            return t
        }
        lightThemes.append(contentsOf: defaultThemes)
        // custom themes
        let customThemes = business.getCustomLightThemes()?.map({ $0.markdownTheme }) ?? []
        lightThemes.append(contentsOf: customThemes)
    }
    
    func loadDarkThemes() {
        darkThemes.removeAll()
        
        let defaultsThemesList = business.getDefaultDarkThemes()
        let defaultThemes = defaultsThemesList.map { theme in
            var t = theme.markdownTheme
            t.isCustomTheme = false
            return t
        }
        darkThemes.append(contentsOf: defaultThemes)
        // custom themes
        let customThemes = business.getCustomDarkThemes()?.map({ $0.markdownTheme }) ?? []
        darkThemes.append(contentsOf: customThemes)
    }
    
    func saveTheme(newValue: ThemeVS, appearanceType: AppearanceType) {
        var newValue = newValue
        newValue.id = UUID()
        newValue.isCustomTheme = true
        
        if appearanceType == .light {
            business.appendCustomLightTheme(newTheme: newValue.theme)
            lightThemes.append(newValue)
            themes.append(newValue)
        } else {
            business.appendCustomDarkTheme(newTheme: newValue.theme)
            darkThemes.append(newValue)
            themes.append(newValue)
        }
    }
    
    func deleteTheme(newValue: ThemeVS, appearanceType: AppearanceType) {
        if appearanceType == .light {
            business.deleteCustomLightTheme(newValue.id)
            lightThemes.removeAll(where: { $0.id == newValue.id })
        } else {
            business.deleteCustomDarkTheme(newValue.id)
            darkThemes.removeAll(where: { $0.id == newValue.id })
        }
        themes.removeAll(where: { $0.id == newValue.id })
    }
    
}
