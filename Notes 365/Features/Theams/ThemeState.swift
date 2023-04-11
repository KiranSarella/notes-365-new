//
//  ThemeState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI
import Combine


/*
 manages current theme
 listen to theme changes
 listen to system light, dark mode changes
 */
class ThemeState: ObservableObject {
    
    static let shared = ThemeState()
    
    @Published var colorScheme: ColorScheme = .light
    
    @Published var theme: MarkdownTheme!
    
    var cancellable: Cancellable?
    
    init() {
        observeColorSchemaChanges()
        loadTheme(colorScheme: colorScheme)
    }

    func observeColorSchemaChanges() {
        cancellable = $colorScheme.sink { newValue in
            if newValue !=  self.colorScheme {
                self.loadTheme(colorScheme: newValue)
            }
        }
    }
    
    private func loadTheme(colorScheme: ColorScheme) {
        if colorScheme == .light {
            theme = ThemeBusiness().getLightTheme()
        } else {
            theme = ThemeBusiness().getDarkTheme()
        }
    }
    
    // trigged on 'save changes' action
    func themeUpdated(newValue: MarkdownTheme) {
        // if updated is current theme, then update immediately
        if theme.id == newValue.id {
            theme = newValue
        }
    }
    
    // trigged on 'set light/dark' action
    func themeChanged(for mode: ColorScheme, newValue: MarkdownTheme) {
        // if theme modified on current mode, the update with new theme
        if colorScheme == mode {
            theme = newValue
        }
    }
}
