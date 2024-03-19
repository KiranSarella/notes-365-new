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
}

extension ThemeBusiness {
    
    func getDefaultLightThemes() -> [Theme] {
        [
            DefaultThemes.generateBasicLightTheme(),
            DefaultThemes.generateCustomizedLightTheme(),
            DefaultThemes.ashLightTheme(),
            DefaultThemes.lightPurpleLightTheme()
        ]
    }
    
    func getDefaultDarkThemes() -> [Theme] {
        [
            DefaultThemes.generateBasicDarkTheme(),
            DefaultThemes.generateCustomizedDarkTheme(),
            DefaultThemes.GrayDarkTheme()
        ]
    }
    
}
