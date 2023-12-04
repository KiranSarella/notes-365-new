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
    @State private var lightThemes = [MarkdownTheme]()
    @State private var darkThemes = [MarkdownTheme]()
    @State private var selectedLightTheme: MarkdownTheme = BusinessFactory.themeInteractor().getLightTheme().markdownTheme
    @State private var selectedDarkTheme: MarkdownTheme = BusinessFactory.themeInteractor().getDarkTheme().markdownTheme
    
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
                    ThemeOptionsView(theme: $selectedLightTheme)
                case .dark:
                    ThemeOptionsView(theme: $selectedDarkTheme)
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
                        persistThemeChanges()
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
        }
        .onAppear {
            lightThemes = themeBusiness.fetchLightThemes().map { $0.markdownTheme }
            darkThemes = themeBusiness.fetchDarkThemes().map { $0.markdownTheme }
            
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
    
    func persistThemeChanges() {
        do {
            switch appearanceType {
            case .light:
                try themeBusiness.update(theme: selectedLightTheme.theme)
                if ThemeState.shared.theme.id == selectedLightTheme.id {
                    ThemeState.shared.themeUpdated(newValue: selectedLightTheme)
                }
            case .dark:
                try themeBusiness.update(theme: selectedDarkTheme.theme)
                if ThemeState.shared.theme.id == selectedDarkTheme.id {
                    ThemeState.shared.themeUpdated(newValue: selectedDarkTheme)
                }
            }
        } catch let error {
            logger.error("\(error)")
        }
    }
}

#Preview {
    ThemesBaseView()
}
