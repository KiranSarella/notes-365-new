//
//  ThemesListState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI

class ThemesListState: ObservableObject {
    
    private let themeBusiness = ThemeBusiness()
    
    @Published var themes = [MarkdownTheme]()
    @Published var selectedLightTheme: MarkdownTheme
    @Published var selectedDarkTheme: MarkdownTheme
    
    init() {
        // get themes
        let themesList = themeBusiness.getThemes()
        themes = themesList
        // get selected theme index
        selectedLightTheme = themeBusiness.getLightTheme()
        selectedDarkTheme = themeBusiness.getDarkTheme()
        print(themesList)
    }
    
    func saveChanges(_ modifiedTheme: MarkdownTheme) {
        
        let index = themes.firstIndex { t in
            modifiedTheme.id == t.id
        }
        
        if let index = index {
            themes[index] = modifiedTheme
            // presist changes
            persistThemes()
            // notify changes
            ThemeState.shared.themeUpdated(newValue: modifiedTheme)
        }
    }
    
    func persistThemes() {
        themeBusiness.saveThemes(themes: themes)
    }
    
    func saveLightTheme(_ newValueID: UUID) {
        if let newValue = themes.first(where: { $0.id == newValueID }) {
            ThemeState.shared.themeChanged(for: .light, newValue: newValue)
            themeBusiness.saveLightTheme(id: newValue.id.uuidString)
        }
    }
    
    func saveDarkTheme(_ newValueID: UUID) {
        if let newValue = themes.first(where: { $0.id == newValueID }) {
            ThemeState.shared.themeChanged(for: .dark, newValue: newValue)
            themeBusiness.saveDarkTheme(id: newValue.id.uuidString)
        }
    }
    
//    func getSelectedThemeIndex() -> Int {
//
//        if let selectedTheme = selectedThemeID {
//            let index = themesListState.themes.firstIndex { theme in
//                theme.id == selectedTheme
//            }
//            if let index = index {
//                return index
//            }
//        }
//
//        return 0 // defauts to first theme
//    }
    
}
