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
}
