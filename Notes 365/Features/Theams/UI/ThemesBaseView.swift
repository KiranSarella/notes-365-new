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
    @State private var selectedLightTheme: MarkdownTheme = BusinessFactory.themeInteractor().getLightTheme().markdownTheme
    @State private var selectedDarkTheme: MarkdownTheme = BusinessFactory.themeInteractor().getDarkTheme().markdownTheme
    @State var onReset = false
    
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
                    ThemeOptionsView(theme: $selectedLightTheme, onReset: $onReset, defaultThemes: themeBusiness.getDefaultLightThemes())
                case .dark:
                    ThemeOptionsView(theme: $selectedDarkTheme, onReset: $onReset, defaultThemes: themeBusiness.getDefaultDarkThemes())
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
                        resetTheme()
                        persistThemeChanges()
                    } label: {
                        Text("Reset")
                    }
                    
                    Button {
                        persistThemeChanges()
//                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
        }
        .onAppear {
            logger.debug("onAppear - ThemeBaseView")
            switch colorScheme {
            case .light:
                appearanceType = .light
            case .dark:
                appearanceType = .dark
            @unknown default:
                appearanceType = .light
            }
        }
    }
    
    func resetTheme() {
        switch appearanceType {
        case .light:
            selectedLightTheme = DefaultThemes.generateCustomizedLightTheme().markdownTheme
        case .dark:
            selectedDarkTheme = DefaultThemes.generateCustomizedDarkTheme().markdownTheme
        }
        onReset.toggle()
    }
    
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
}

#Preview {
    ThemesBaseView()
}
