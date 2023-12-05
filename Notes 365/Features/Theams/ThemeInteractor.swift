//
//  ThemeInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 03/12/23.
//

import Foundation

protocol ThemeInteractor {
//    func fetchLightThemes() -> [Theme]
//    func fetchDarkThemes() -> [Theme]
    
    func getLightTheme() -> Theme
    func getDarkTheme() -> Theme
    func saveLightTheme(_ theme: Theme)
    func saveDarkTheme(_ theme: Theme)
    
//    func insert(theme: Theme) throws
//    func update(theme: Theme) throws
//    func setLightTheme(id: String)
//    func setDarkTheme(id: String)
}

extension ThemeBusiness: ThemeInteractor {
    
}
