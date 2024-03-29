//
//  ThemeStorage.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftData

class ThemeStorage {
    private let themeLightKey = "com.sarella.notes365.theme_light"
    private let themeDarkKey = "com.sarella.notes365.theme_dark"
    
    private let customLightThemesKey = "com.sarella.notes365.light_themes"
    private let customDarkThemesKey = "com.sarella.notes365.dark_themes"
    
    
    var modelContext: ModelContext
    var defaults = UserDefaults.standard
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
//    func fetchThemes(for appearanceType: String) throws -> [ThemeData] {
//        let contentPredicate = #Predicate<ThemeData> {
//            $0.appearanceType == appearanceType
//        }
//        let sortDescriptor = SortDescriptor(\ThemeData.themeName)
//        let descriptor = FetchDescriptor(predicate: contentPredicate, sortBy: [sortDescriptor])
//        return try modelContext.fetch(descriptor)
//    }
//    
//    func fetchTheme(id: UUID) throws -> ThemeData? {
//        let predicate = #Predicate<ThemeData> { $0.id == id }
//        var descriptor = FetchDescriptor(predicate: predicate)
//        descriptor.fetchLimit = 1
//        return try modelContext.fetch(descriptor).first
//    }
//    
//    func containThemes() throws -> Bool {
//        let contentPredicate = #Predicate<ThemeData> { _ in true }
//        let descriptor = FetchDescriptor(predicate: contentPredicate)
//        return try modelContext.fetchCount(descriptor) > 0
//    }
//    
//    func insert(themeData: ThemeData) throws {
//        modelContext.insert(themeData)
//        try modelContext.save()
//        logger.info("inserted: \(themeData)")
//    }
//   
//    func update(themeData: ThemeData) throws {
//        let existingData = try fetchTheme(id: themeData.id)
//        existingData?.sync(newData: themeData)
//        try existingData?.modelContext?.save()
//        logger.info("updated: \(existingData?.description ?? "")")
//    }
//    
    // MARK: - User Defaults
//    func setLightTheme(id: String) {
//        UserDefaults.standard.set(id, forKey: themeLightKey)
//    }
//    
//    func setDarkTheme(id: String) {
//        UserDefaults.standard.set(id, forKey: themeDarkKey)
//    }
//    
//    func fetchLightTheme() -> String? {
//        UserDefaults.standard.value(forKey: themeLightKey) as? String
//    }
//    
//    func fetchDarkTheme() -> String?   {
//        UserDefaults.standard.value(forKey: themeDarkKey) as? String
//    }
    
    // light themes
    func getCustomLightThemes() -> [ThemeData]? {
        if let data = defaults.object(forKey: customLightThemesKey) as? Data {
           return try? JSONDecoder().decode([ThemeData].self, from: data)
        }
        return nil
    }
    
    func appendCustomLightTheme(newTheme: ThemeData) {
        var lightThemes = getCustomLightThemes() ?? []
        lightThemes.append(newTheme)
        
        persistListChanges(themes: lightThemes, key: customLightThemesKey)
    }
    
    func deleteCustomLightTheme(_ id: UUID) {
        var lightThemes = getCustomLightThemes() ?? []
        lightThemes.removeAll { t in
            t.id == id
        }
        
        persistListChanges(themes: lightThemes, key: customLightThemesKey)
    }
    
    // dark themes
    func getCustomDarkThemes() -> [ThemeData]? {
        if let data = defaults.object(forKey: customDarkThemesKey) as? Data {
           return try? JSONDecoder().decode([ThemeData].self, from: data)
        }
        return nil
    }
    
    func appendCustomDarkTheme(newTheme: ThemeData) {
        var themes = getCustomDarkThemes() ?? []
        themes.append(newTheme)
        
        persistListChanges(themes: themes, key: customDarkThemesKey)
    }
    
    func deleteCustomDarkTheme(_ id: UUID) {
        var themes = getCustomDarkThemes() ?? []
        themes.removeAll { t in
            t.id == id
        }
        
        persistListChanges(themes: themes, key: customDarkThemesKey)
    }
    
    // persist
    private func persistListChanges(themes: [ThemeData], key: String) {
        if let data = try? JSONEncoder().encode(themes) {
            defaults.set(data, forKey: key)
        }
    }
    
    // MARK: - selected theme
    
    func saveLightTheme(_ theme: ThemeData) {
        if let data = try? JSONEncoder().encode(theme) {
            defaults.set(data, forKey: themeLightKey)
        }
    }
    
    func saveDarkTheme(_ theme: ThemeData) {
        if let data = try? JSONEncoder().encode(theme) {
            defaults.set(data, forKey: themeDarkKey)
        }
    }
    
    func fetchLightTheme() -> ThemeData? {
        if let data = defaults.object(forKey: themeLightKey) as? Data {
           return try? JSONDecoder().decode(ThemeData.self, from: data)
        }
        return nil
    }
    
    func fetchDarkTheme() -> ThemeData?   {
        if let data = defaults.object(forKey: themeDarkKey) as? Data {
           return try? JSONDecoder().decode(ThemeData.self, from: data)
        }
        return nil
    }
    
}
