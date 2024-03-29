//
//  ThemesBaseView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import SwiftUI

enum AppearanceType: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    var id: Self { self }
}


struct ThemesBaseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let themeBusiness = BusinessFactory.themeInteractor()
    @State private var appearanceType: AppearanceType = .light
    @State private var selectedLightTheme: ThemeVS = BusinessFactory.themeInteractor().getLightTheme().markdownTheme
    @State private var selectedDarkTheme: ThemeVS = BusinessFactory.themeInteractor().getDarkTheme().markdownTheme
    @State var onReset = false
    
    @State var selectedDefaultTheme: ThemeVS?
    @State var deleteThemeEvent: ThemeVS?
    
    @State var state = ThemesBaseViewState()
    
    func updateWithDefault(_ theme: Theme) {
//        self.theme.fontSize = theme.fontSize
//        self.theme.canvasColor = theme.canvasColor
//        self.theme.bodyColor = theme.bodyColor
//        self.theme.headingColor = theme.headingColor
//        self.theme.styleColor = theme.styleColor
//        self.theme.highlightColor = theme.highlightColor
//        self.theme.codeColor = theme.codeColor
//        self.theme.blockQuoteColor = theme.blockQuoteColor
//        self.theme.listColor = theme.listColor
//        self.theme.linkColor = theme.linkColor
//        self.theme.headingFontName = theme.headingFontName
//        self.theme.blockQuoteFontName = theme.blockQuoteFontName
//        
//        self.theme.enableBackground = theme.enableBackground
//        self.theme.enableHeadingFont = theme.enableHeadingFont
//        self.theme.enableBlockQuoteFont = theme.enableBlockQuoteFont
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Appearance Type", selection: $appearanceType) {
                   ForEach(AppearanceType.allCases) { type in
                       Text(type.rawValue.capitalized)
                   }
                }
                .padding()
                switch appearanceType {
                case .light:
                    ThemeOptionsView(theme: $selectedLightTheme, onReset: $onReset, themes: $state.themes, selectedDefaultTheme: $selectedDefaultTheme, deletedThemeEvent: $deleteThemeEvent)
                case .dark:
                    ThemeOptionsView(theme: $selectedDarkTheme, onReset: $onReset,themes: $state.themes, selectedDefaultTheme: $selectedDefaultTheme, deletedThemeEvent: $deleteThemeEvent)
                }
            }
            .pickerStyle(.segmented)
            .toolbar {
                #if targetEnvironment(macCatalyst)
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                #endif
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
                    Button {
                        saveAsNewTheme()
                    } label: {
                        Text("Create As")
                    }
                    
                    Button {
                        persistThemeChanges()
                    } label: {
                        Text("Apply")
                    }
                }
            }
        }
        .onAppear {
            logger.debug("onAppear - ThemeBaseView")
            switch colorScheme {
            case .light:
                appearanceType = .light
                state.setLightThemes()
            case .dark:
                appearanceType = .dark
                state.setDarkThemes()
            @unknown default:
                appearanceType = .light
                state.setLightThemes()
            }
        }
        .onChange(of: selectedDefaultTheme) { oldValue, newValue in
            guard let newValue = newValue else { return }
            
            reset(with: newValue)
        }
        .onChange(of: deleteThemeEvent) { oldValue, newValue in
            guard let newValue = newValue else { return }
            
            state.deleteTheme(newValue: newValue, appearanceType: appearanceType)
            deleteThemeEvent = nil
        }
        .onChange(of: appearanceType) { oldValue, newValue in
            switch newValue {
            case .light:
                state.setLightThemes()
            case .dark:
                state.setDarkThemes()
            }
        }
    }
    
    func reset(with newTheme: ThemeVS) {
        switch appearanceType {
        case .light:
            selectedLightTheme = newTheme
        case .dark:
            selectedDarkTheme = newTheme
        }
        onReset.toggle()
        persistThemeChanges()
    }
    
//    func resetTheme() {
//        switch appearanceType {
//        case .light:
//            selectedLightTheme = DefaultThemes.generateCustomizedLightTheme().markdownTheme
//        case .dark:
//            selectedDarkTheme = DefaultThemes.generateCustomizedDarkTheme().markdownTheme
//        }
//        onReset.toggle()
//    }
    
    func persistThemeChanges() {
        switch appearanceType {
        case .light:
            themeBusiness.saveLightTheme(selectedLightTheme.theme)
            if ThemeState.shared.theme.appearanceType == .light {
                ThemeState.shared.themeUpdated(newValue: selectedLightTheme)
            }
        case .dark:
            themeBusiness.saveDarkTheme(selectedDarkTheme.theme)
            if ThemeState.shared.theme.appearanceType == .dark {
                ThemeState.shared.themeUpdated(newValue: selectedDarkTheme)
            }
        }
    }
    
    func saveAsNewTheme() {
        switch appearanceType {
        case .light:
            state.saveTheme(newValue: selectedLightTheme, appearanceType: appearanceType)
        case .dark:
            state.saveTheme(newValue: selectedDarkTheme, appearanceType: appearanceType)
        }
        
    }
    
    
    
}

#Preview {
    ThemesBaseView()
}
