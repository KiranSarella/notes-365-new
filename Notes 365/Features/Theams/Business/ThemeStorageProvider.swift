//
//  ThemeStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation

protocol ThemeStorageProvider {
    func saveLightTheme(_ theme: Theme)
    func saveDarkTheme(_ theme: Theme)
    func fetchLightTheme() -> Theme?
    func fetchDarkTheme() -> Theme?
    
    // MARK: - custom light themes
    func getCustomLightThemes() -> [Theme]?
    func appendCustomLightTheme(newTheme: Theme)
    func deleteCustomLightTheme(_ id: UUID)
    // MARK: - custom dark themes
    func getCustomDarkThemes() -> [Theme]?
    func appendCustomDarkTheme(newTheme: Theme)
    func deleteCustomDarkTheme(_ id: UUID)
}
