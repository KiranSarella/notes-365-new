//
//  TheamSettingsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import SwiftUI

struct ThemesListView: View {
    
    @StateObject private var themesListState = ThemesListState()
    @State private var selectedThemeID: MarkdownTheme.ID = UUID()
    @State private var selectedLightThemeID: MarkdownTheme.ID = UUID()
    @State private var selectedDarkThemeID: MarkdownTheme.ID = UUID()
    @State private var showDetail = false
    @State private var selectedTheme: MarkdownTheme?
    
    
    var body: some View {
        HStack {
            VStack {
                #if os(macOS)
                List(themesListState.themes, selection: $selectedThemeID) { theme in
                    Text(theme.themeName)
                }
                #endif
                Spacer()
                // selection pickers
                VStack {
                    Picker("Light", selection: $selectedLightThemeID) {
                        ForEach(themesListState.themes) { theme in
                            Text(theme.themeName).lineLimit(1).tag(theme.id)
                        }
                    }
                    Picker("Dark", selection: $selectedDarkThemeID) {
                        ForEach(themesListState.themes, id:\.self) { theme in
                            Text(theme.themeName).tag(theme.id)
                        }
                    }
                }
                .padding()
                .onChange(of: selectedLightThemeID) { newValue in
                    themesListState.saveLightTheme(newValue)
                }
                .onChange(of: selectedDarkThemeID) { newValue in
                    themesListState.saveDarkTheme(newValue)
                }
                    
            }.frame(width: 200)
                .background(Color("ListBackground"))
            
            // detail view
            if showDetail {
                #if os(macOS)
                if let themee = themesListState.themes.first { $0.id == selectedThemeID } {
                    ThemeDetailView(theme: Binding.constant(themee)) { modifiedTheme in
                        themesListState.saveChanges(modifiedTheme)
                    }
                }
                #endif
            }
            
            Spacer()
        }
        .onChange(of: selectedThemeID, perform: { newValue in
            showDetail = false
            Task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDetail = true
                }
            }
        })
        .onAppear {
            // by default select/highlight current theme in the list
            selectedThemeID = ThemeState.shared.theme.id
            selectedLightThemeID = themesListState.selectedLightTheme.id
            selectedDarkThemeID = themesListState.selectedDarkTheme.id
        }
//        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.save_object"))) { output in
//
//            guard let newSelectedIndex = output.object as? Int else { return }
//
//            let themeManager = ThemeManager.shared
//
//            themeManager.themes[newSelectedIndex] = themesListState.themes[newSelectedIndex]
//            themeManager.selectedThemeIndex = newSelectedIndex
//            themeManager.saveThemeState()
//
//            NotificationCenter.default.post(name: Notification.Name("theme.modified"), object: themesListState.themes[newSelectedIndex])
//        }
    }
}

