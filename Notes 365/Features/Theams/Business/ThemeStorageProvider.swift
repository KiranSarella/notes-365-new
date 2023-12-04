//
//  ThemeStorageProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation

protocol ThemeStorageProvider {
    func fetchThemes(for appearanceType: AppearanceType) throws -> [Theme]
    func fetchTheme(id: UUID) throws -> Theme?
    func containThemes() throws -> Bool
    func insert(theme: Theme) throws
    func update(theme: Theme) throws
    func setLightTheme(id: String)
    func setDarkTheme(id: String)
    func fetchLightTheme() -> String?
    func fetchDarkTheme() -> String?
}
