//
//  ThemeState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI


/*
 manages current theme
 listen to theme changes
 listen to system light, dark mode changes
 */
class ThemeState: ObservableObject {
    
    static let shared = ThemeState()
    
    @Environment(\.colorScheme) var colorScheme
    
    @Published var theme: MarkdownTheme!
    
    init() {
        
        loadTheme()
    }
    
    private func loadTheme() {
        if colorScheme == .light {
            theme = ThemeBusiness().getLightTheme()
        } else {
            theme = ThemeBusiness().getDarkTheme()
        }
    }
    
    func didColorSchemeChange() {
        loadTheme()
    }
}
