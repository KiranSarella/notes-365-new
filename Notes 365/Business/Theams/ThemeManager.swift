//
//  ThemeManager.swift
//  Notes 365
//
//  Created by Kiran Sarella on 10/07/22.
//

import Foundation
import SwiftUI


class ThemeManager: ObservableObject, Codable {
    
    let themeManagerKey = "theme_manager_ud"
    
    @Published var themes: [MarkdownTheme]
    @Published var selectedThemeIndex: Int
    
    static let shared: ThemeManager = ThemeManager(loadFromDefaults: true)
    
    init(loadFromDefaults: Bool) {
        
        if loadFromDefaults == false {
            
            themes = ThemeBusiness.getDefaultTheams()
            selectedThemeIndex = 0
            
            return
        }
        
        if let data = UserDefaults.standard.value(forKey: themeManagerKey) as? Data {
            
            if let obj = try? PropertyListDecoder().decode([MarkdownTheme].self, from: data) {
                self.themes = obj
            } else {
                themes = ThemeBusiness.getDefaultTheams()
            }
        } else {
            themes = ThemeBusiness.getDefaultTheams()
        }
        
        if let selectedIndex = UserDefaults.standard.object(forKey: "selected_theme_index") as? Int {
            self.selectedThemeIndex = selectedIndex
        } else {
            self.selectedThemeIndex = 0
        }
    }
    
    func getSelectedTheme() -> MarkdownTheme {
        return self.themes[selectedThemeIndex]
    }
    
    func resetThemesFromStorage() {
        if let data = UserDefaults.standard.value(forKey: themeManagerKey) as? Data {
            
            if let obj = try? PropertyListDecoder().decode([MarkdownTheme].self, from: data) {
                self.themes = obj
            } else {
                themes = ThemeBusiness.getDefaultTheams()
            }
        } else {
            themes = ThemeBusiness.getDefaultTheams()
        }
    }
    
    func resetSavedThemes() {
        themes = ThemeBusiness.getDefaultTheams()
        self.selectedThemeIndex = 0
        
        saveThemeState()
    }
    
    func clearSavedThemes() {
        
        UserDefaults.standard.removeObject(forKey: themeManagerKey)
        UserDefaults.standard.removeObject(forKey: "selected_theme_index")
    }
    
    func saveThemeState() {
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(themes), forKey: themeManagerKey)
        UserDefaults.standard.set(selectedThemeIndex, forKey: "selected_theme_index")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // body
        themes = try container.decode([MarkdownTheme].self, forKey: .themes)
        selectedThemeIndex = try container.decode(Int.self, forKey: .selectedThemeIndex)
    }
}
//
//extension ThemeManager {
//    // create clone
//    func createClone -> ThemeManager {
//        theme
//    }
//
//}

extension ThemeManager: Equatable {
    static func == (lhs: ThemeManager, rhs: ThemeManager) -> Bool {
        return lhs.themes.count == rhs.themes.count && lhs.selectedThemeIndex == rhs.selectedThemeIndex
    }
}

extension ThemeManager  {
    
    enum CodingKeys: CodingKey {
        case themes, selectedThemeIndex
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(themes, forKey: .themes)
        try container.encode(selectedThemeIndex, forKey: .selectedThemeIndex)
    }
}

