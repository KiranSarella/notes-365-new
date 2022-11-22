//
//  TheamSettingsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/06/22.
//

import SwiftUI


struct TheamSettingsView: View {
    
    // storage
    
    // local
    @State private var themes: [MarkdownTheme]
    @State private var selectedThemeIndex: Int
    @State private var selectedThemeID: MarkdownTheme.ID?

    init() {
    
        let themeManager = ThemeManager.shared
        
        _themes = State(initialValue: themeManager.themes)
        _selectedThemeIndex = State(initialValue: themeManager.selectedThemeIndex)
        _selectedThemeID = State(initialValue: themes[themeManager.selectedThemeIndex].id)
    }
    
    func getSelectedThemeIndex() -> Int {
        
        if let selectedTheme = selectedThemeID {
            let index = themes.firstIndex { theme in
                theme.id == selectedTheme
            }
            if let index = index {
                return index
            }
        }
            
        return 0 // defauts to first theme
    }
    
    var body: some View {
        
        HStack {
            NavigationView {
                List($themes) { $theme in
                    NavigationLink(tag: theme.id, selection: $selectedThemeID) {
                        ThemeDetailView(theme: $theme, selectedThemeIndex: getSelectedThemeIndex(), globalColor: theme.bodyColor)
                    } label: {
                        Text(theme.themeName)
                    }
                }
                .frame(width: 200)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("theme.save_object"))) { output in
            
            guard let newSelectedIndex = output.object as? Int else { return }

            let themeManager = ThemeManager.shared

            themeManager.themes[newSelectedIndex] = themes[newSelectedIndex]
            themeManager.selectedThemeIndex = newSelectedIndex
            themeManager.saveThemeState()

            NotificationCenter.default.post(name: Notification.Name("theme.modified"), object: themes[newSelectedIndex])
        }
    }
}





//struct TheamSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TheamSettingsView()
//    }
//}
