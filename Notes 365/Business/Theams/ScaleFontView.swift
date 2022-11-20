//
//  ScaleFontView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 10/07/22.
//

import SwiftUI

struct ScaleFontView: View {
    
    @Binding var theme: MarkdownTheme
    
    var body: some View {
        // scale font size
        HStack {
            Button {
                theme.font = theme.font.withSize(theme.font.pointSize - 2)
                
                let index = ThemeManager.shared.themes.firstIndex { t in
                    theme.themeName == t.themeName
                }
                
                if let index = index {
                    ThemeManager.shared.themes[index] = theme
                    ThemeManager.shared.saveThemeState()
                }
                
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .padding(.leading)
            
            Divider()
            
            Button {
                theme.font = theme.font.withSize(theme.font.pointSize + 2)
                let index = ThemeManager.shared.themes.firstIndex { t in
                    theme.themeName == t.themeName
                }
                
                if let index = index {
                    ThemeManager.shared.themes[index] = theme
                    ThemeManager.shared.saveThemeState()
                }
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .padding(.trailing)
        }
        .buttonStyle(.plain)
        
    }
}

