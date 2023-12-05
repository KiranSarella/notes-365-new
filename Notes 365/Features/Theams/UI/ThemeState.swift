//
//  ThemeState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI
import Combine

@Observable
class ThemeState {
    static let shared = ThemeState()
    private(set) var colorScheme: ColorScheme = .light
    private(set) var theme: MarkdownTheme! = MarkdownTheme(id: UUID())
    private var cancellable: Cancellable? = nil
    var business = BusinessFactory.themeInteractor()
    
    init() {
//        loadTheme(colorScheme: colorScheme)
    }
    
    private func loadTheme(colorScheme: ColorScheme) {
        if colorScheme == .light {
            theme = business.getLightTheme().markdownTheme
            themeChangedNotification()
        } else {
            theme = business.getDarkTheme().markdownTheme
            themeChangedNotification()
        }
    }
    
    func updateColorScheme(_ newValue: ColorScheme) {
        colorScheme = newValue
        self.loadTheme(colorScheme: colorScheme)
    }
    
    // trigged on 'save changes' action
    func themeUpdated(newValue: MarkdownTheme) {
        theme = newValue
        themeChangedNotification()
        
//        // if updated is current theme, then update immediately
//        if theme.id == newValue.id {
//            theme = newValue
//            themeChangedNotification()
//        }
    }
    
    // trigged on 'set light/dark' action
    func themeChanged(for mode: ColorScheme, newValue: MarkdownTheme) {
        // if theme modified on current mode, the update with new theme
        if colorScheme == mode {
            theme = newValue
            themeChangedNotification()
        }
    }
    
    // send notification
    func themeChangedNotification() {
        NotificationCenter.default.post(name: .themeUpdated, object: theme)
    }
}

public extension NSNotification.Name {
    static let themeUpdated = NSNotification.Name("notes365.theme.updated")
}
