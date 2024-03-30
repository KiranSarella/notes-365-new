//
//  ThemeBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import Foundation

class ThemeBusiness {
    var storage: ThemeStorageProvider
    init(storage: ThemeStorageProvider) {
        self.storage = storage
    }
    
    func getLightTheme() -> Theme {
        logger.debug("\(#function)")
        if let theme = storage.fetchLightTheme() {
            return theme
        } else {
            return DefaultThemes.generateCustomizedLightTheme()
        }
    }
    
    func getDarkTheme() -> Theme {
        logger.debug("\(#function)")
        if let theme = storage.fetchDarkTheme() {
            return theme
        } else {
            return DefaultThemes.generateCustomizedDarkTheme()
        }
    }
    
    func saveLightTheme(_ theme: Theme) {
        storage.saveLightTheme(theme)
    }
    
    func saveDarkTheme(_ theme: Theme) {
        storage.saveDarkTheme(theme)
    }
    
    // MARK: - custom light themes
    func getCustomLightThemes() -> [Theme]? {
        storage.getCustomLightThemes()
    }
    
    func appendCustomLightTheme(newTheme: Theme) {
        storage.appendCustomLightTheme(newTheme: newTheme)
    }
    
    func deleteCustomLightTheme(_ id: UUID) {
        storage.deleteCustomLightTheme(id)
    }
    
    // MARK: - custom dark themes
    func getCustomDarkThemes() -> [Theme]? {
        storage.getCustomDarkThemes()
    }
    
    func appendCustomDarkTheme(newTheme: Theme) {
        storage.appendCustomDarkTheme(newTheme: newTheme)
    }
    
    func deleteCustomDarkTheme(_ id: UUID) {
        storage.deleteCustomDarkTheme(id)
    }
    
}

extension ThemeBusiness {
    
    func getDefaultLightThemes() -> [Theme] {
        [
            DefaultThemes.generateGrayTheme(),
            
            DefaultThemes.generateBlueTheme(),
            
            DefaultThemes.generateGreenTheme(),
            
            DefaultThemes.generateBeigeTheme(),
            
            DefaultThemes.generateLavenderTheme(),
            
            DefaultThemes.generateCustomizedLightTheme(),
            DefaultThemes.ashLightTheme(),
            DefaultThemes.lightPurpleLightTheme()
        ]
    }
    
    func getDefaultDarkThemes() -> [Theme] {
        [
            DefaultThemes.generateBasicDarkTheme(),
            DefaultThemes.generateGoldCharcoalTheme(),
            DefaultThemes.generateCustomizedDarkTheme(),
            DefaultThemes.GrayDarkTheme()
        ]
    }
    
}
