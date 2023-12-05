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
//        cofigThemes()
    }
    
    /*
    private func cofigThemes() {
        logger.debug("\(#function)")
        do {
            let containsThemes = try storage.containThemes()
            if !containsThemes {
                setDefaultThemes()
            }
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    private func setDefaultThemes() {
        logger.debug("\(#function)")
        let defaultThemes = DefaultThemes.loadTheams()
        do {
            for theme in defaultThemes {
                try storage.insert(theme: theme)
            }
            storage.setLightTheme(id: defaultThemes[2].id.uuidString)
            storage.setDarkTheme(id: defaultThemes[3].id.uuidString)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func fetchLightThemes() -> [Theme] {
        logger.debug("\(#function)")
        return try! storage.fetchThemes(for: .light)
//        do {
//            return try storage.fetchThemes(for: .light)
//        } catch let error {
//            logger.error("\(error)")
//        }
//        return []
    }
    
    func fetchDarkThemes() -> [Theme] {
        logger.debug("\(#function)")
        return try! storage.fetchThemes(for: .dark)
//        do {
//            return try storage.fetchThemes(for: .dark)
//        } catch let error {
//            logger.error("\(error)")
//        }
//        return []
    }
    
    func getLightTheme() -> Theme {
        logger.debug("\(#function)")
        let themeIdStr = storage.fetchLightTheme()!
        let themeId = UUID(uuidString: themeIdStr)!
        return try! storage.fetchTheme(id: themeId)!
//        do {
//            if let themeIdStr = storage.fetchLightTheme() {
//                if let themeId = UUID(uuidString: themeIdStr) {
//                    if let theme = try storage.fetchTheme(id: themeId) {
//                        return theme
//                    }
//                }
//            }
//        } catch let error {
//            logger.error("\(error)")
//        }
//        return DefaultThemes.generateCustomizedLightTheme()
    }
    
    func getDarkTheme() -> Theme {
        logger.debug("\(#function)")
        let themeIdStr = storage.fetchDarkTheme()!
        let themeId = UUID(uuidString: themeIdStr)!
        return try! storage.fetchTheme(id: themeId)!
//        do {
//            if let themeIdStr = storage.fetchDarkTheme() {
//                if let themeId = UUID(uuidString: themeIdStr) {
//                    if let theme = try storage.fetchTheme(id: themeId) {
//                        return theme
//                    }
//                }
//            }
//        } catch let error {
//            logger.error("\(error)")
//        }
//        return DefaultThemes.generateCustomizedDarkTheme()
    }
    
    func insert(theme: Theme) {
        do {
            try storage.insert(theme: theme)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func update(theme: Theme) throws {
        do {
            try storage.update(theme: theme)
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func setLightTheme(id: String) {
        storage.setLightTheme(id: id)
    }
    
    func setDarkTheme(id: String) {
        storage.setDarkTheme(id: id)
    }
     */
    
    
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
