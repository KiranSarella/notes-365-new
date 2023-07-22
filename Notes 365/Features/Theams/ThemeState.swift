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

@Observable
class ThemeState {
    
    static let shared = ThemeState()
    
    var colorScheme: ColorScheme = .light
    
    var theme: MarkdownTheme! = ThemeBusiness().getLightTheme()
    
    
    var themePub = CurrentValueSubject<MarkdownTheme, Never>(ThemeBusiness().getLightTheme())
    
    var cancellable: Cancellable? = nil
    
    init() {
//        observeColorSchemaChanges()
        loadTheme(colorScheme: colorScheme)
    }

    func didChange(colorSchema newValue: ColorScheme) {
        if newValue !=  self.colorScheme {
            self.colorScheme = newValue
            self.loadTheme(colorScheme: newValue)
        }
    }
    
    private func loadTheme(colorScheme: ColorScheme) {
        if colorScheme == .light {
            theme = ThemeBusiness().getLightTheme()
        } else {
            theme = ThemeBusiness().getDarkTheme()
        }
        
        themePub.send(theme)
    }
    
    // trigged on 'save changes' action
    func themeUpdated(newValue: MarkdownTheme) {
        // if updated is current theme, then update immediately
        if theme.id == newValue.id {
            theme = newValue
            
            themePub.send(theme)
        }
    }
    
    // trigged on 'set light/dark' action
    func themeChanged(for mode: ColorScheme, newValue: MarkdownTheme) {
        // if theme modified on current mode, the update with new theme
        if colorScheme == mode {
            theme = newValue
            
            themePub.send(theme)
        }
    }
}
