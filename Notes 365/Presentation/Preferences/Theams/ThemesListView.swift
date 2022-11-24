//
//  TheamSettingsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import SwiftUI

struct ThemesListView: View {
    
    @StateObject private var themesListState = ThemesListState()
    @State private var selectedThemeID: MarkdownTheme.ID?
    @State private var showDetail = false
    @State private var selectedTheme: MarkdownTheme?
    
    
    var body: some View {
        HStack {
            VStack {
                // list view
                List(themesListState.themes, selection: $selectedThemeID) { theme in
                    Text(theme.themeName)
                }
                Spacer()
                // selection pickers
                VStack {
                    Picker("Light", selection: $themesListState.selectedLightTheme) {
                        ForEach(themesListState.themes) { theme in
                            Text(theme.themeName).tag(theme)
                        }
                    }
                    Picker("Dark", selection: $themesListState.selectedDarkTheme) {
                        ForEach(themesListState.themes, id:\.self) { theme in
                            Text(theme.themeName).tag(theme)
                        }
                    }
                }.padding()
                    
            }.frame(width: 200)
            
            // detail view
            if showDetail {
                if let themee = themesListState.themes.first { $0.id == selectedThemeID } {
                    ThemeDetailView(theme: Binding.constant(themee)) { modifiedTheme in
                        if let index = themesListState.themes.firstIndex(of: themee) {
                            themesListState.themes[index] = modifiedTheme
                            // presist changes
                            themesListState.persisteThemes()
                        }
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: selectedThemeID, perform: { newValue in
            showDetail = false
            Task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if newValue != nil {
                        showDetail = true
                    }
                }
            }
        })
        .onAppear {
            // by default select/highlight current theme in the list
            selectedThemeID = ThemeState.shared.theme.id
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.save_object"))) { output in
            
            guard let newSelectedIndex = output.object as? Int else { return }

            let themeManager = ThemeManager.shared

            themeManager.themes[newSelectedIndex] = themesListState.themes[newSelectedIndex]
            themeManager.selectedThemeIndex = newSelectedIndex
            themeManager.saveThemeState()

            NotificationCenter.default.post(name: Notification.Name("theme.modified"), object: themesListState.themes[newSelectedIndex])
        }
    }
}

