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
        themes = themeBusiness.getThemes()
        // get selected theme index
        selectedLightTheme = themeBusiness.getLightTheme()
        selectedDarkTheme = themeBusiness.getDarkTheme()
    }
    
    func persisteThemes() {
        print(#function)
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
