//
//  NewThemeState.swift
//  Notes 365
//
//  Created by kiran ipc on 24/07/23.
//

import SwiftUI

enum Appearance: CaseIterable, Identifiable {
    case light
    case dark
    case auto
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .auto:
            return "Auto"
        }
    }
}


enum ThemeBackground: CaseIterable, Identifiable {
    case color
    case image
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .color:
            return "Color"
        case .image:
            return "Image"
        }
    }
}

enum EditorThemeType: String, CaseIterable, Identifiable {
    case light
    case dark
    
    var id: Self { self }
}


@Observable
class NewThemeState {
    
    var appearance: Appearance = .auto
    var background: ThemeBackground = .color
    var editor: EditorThemeType = .light
    var editorID: EditorThemeType.ID = .light.id
    // font name
    var fontName: String = "System"
    var showFontPicker = false
    var font: Font = Font.system(Font.TextStyle.body)
    // font size
    var fontSize = 14
    let step = 2
    let range = 8...64
    // colors
    var bodyColor = Color.black
    var headingColor = Color.black
    var boldColor = Color.black
    var listColor = Color.black
    var codeColor = Color.black
    var quoteColor = Color.black
    
}
