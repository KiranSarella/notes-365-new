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
    private(set) var theme: ThemeVS! = ThemeVS(id: UUID())
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
        logger.debug("\(#function)")
        colorScheme = newValue
        self.loadTheme(colorScheme: colorScheme)
    }
    
    // trigged on 'save changes' action
    func themeUpdated(newValue: ThemeVS) {
        theme = newValue
        themeChangedNotification()
        
//        // if updated is current theme, then update immediately
//        if theme.id == newValue.id {
//            theme = newValue
//            themeChangedNotification()
//        }
    }
    
    
    // trigged on 'set light/dark' action
    func themeChanged(for mode: ColorScheme, newValue: ThemeVS) {
        // if theme modified on current mode, the update with new theme
        if colorScheme == mode {
            theme = newValue
            themeChangedNotification()
        }
    }
    
    // send notification
    func themeChangedNotification() {
//        NotificationCenter.default.post(name: .themeUpdated, object: theme)
        
        let notification = Notification(name: .themeUpdated, object: theme)
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle, coalesceMask: .onName, forModes: nil)
    }
}

public extension NSNotification.Name {
    static let themeUpdated = NSNotification.Name("notes365.theme.updated")
}
