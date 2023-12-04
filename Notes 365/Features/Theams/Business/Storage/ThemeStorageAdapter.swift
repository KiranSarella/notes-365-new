//
//  ThemeStorageAdapter.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftData
import SwiftUI

class ThemeStorageAdapter: ThemeStorageProvider {
    
    let storage: ThemeStorage
    
    init(modelContext: ModelContext) {
        storage = ThemeStorage(modelContext: modelContext)
    }
    
    func fetchThemes(for appearanceType: AppearanceType) throws -> [Theme] {
        try storage.fetchThemes(for: appearanceType.rawValue).map { $0.theme }
    }
    
    func fetchTheme(id: UUID) throws -> Theme? {
        try storage.fetchTheme(id: id)?.theme
    }
    
    func containThemes() throws -> Bool {
        try storage.containThemes()
    }
    
    func insert(theme: Theme) throws {
        try storage.insert(themeData: theme.themeData)
    }
    
    func update(theme: Theme) throws {
        try storage.update(themeData: theme.themeData)
    }
    
    // MARK: - User Defaults
    func setLightTheme(id: String) {
        storage.setLightTheme(id: id)
    }
    
    func setDarkTheme(id: String) {
        storage.setDarkTheme(id: id)
    }
    
    func fetchLightTheme() -> String? {
        storage.fetchLightTheme()
    }
    
    func fetchDarkTheme() -> String? {
        storage.fetchDarkTheme()
    }
    
}


extension ThemeData {
    var theme: Theme {
        var t = Theme(id: id, themeName: themeName, appearanceType: AppearanceType(rawValue: appearanceType)!)
        t.fontName = fontName
        t.fontSize = fontSize
        t.bodyColor = bodyColor.color
        t.headingColor = headingColor.color
        t.styleColor = styleColor.color
        t.highlightColor = highlightColor.color
        t.codeColor = codeColor.color
        t.blockQuoteColor = blockQuoteColor.color
        t.listColor = listColor.color
        t.linkColor = linkColor.color
        return t
    }
}

extension Theme {
    var themeData: ThemeData {
        let t = ThemeData()
        t.id = id
        t.themeName = themeName
        t.appearanceType = appearanceType.rawValue
        t.fontName = fontName
        t.fontSize = fontSize
        t.bodyColor = bodyColor.colorData
        t.headingColor = headingColor.colorData
        t.styleColor = styleColor.colorData
        t.highlightColor = highlightColor.colorData
        t.codeColor = codeColor.colorData
        t.blockQuoteColor = blockQuoteColor.colorData
        t.listColor = listColor.colorData
        t.linkColor = linkColor.colorData
        return t
    }
}

extension Color {
    var colorData: ColorData {
        ColorData(color: self)
    }
}
