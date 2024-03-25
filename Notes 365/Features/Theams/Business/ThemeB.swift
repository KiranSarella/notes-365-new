//
//  Theme.swift
//  Notes 365
//
//  Created by kiran ipc on 02/12/23.
//

import Foundation
import SwiftUI

struct Theme: Identifiable {
    let id: UUID
    let themeName: String
    let appearanceType: AppearanceType

    var fontSize: Float = 16
    
    // font names
    var fontName: String = ""
    var headingFontName: String = ""
    var blockQuoteFontName: String = ""
    var codeFontName: String = ""
    
    // body
    var canvasColor: Color = Color.white
    var bodyColor: Color = Color.primary
    // Heading
    var headingColor: Color = Color.primary
    // bold, italic, strikethrough
    var styleColor: Color = Color.primary
    var highlightColor: Color = Color.primary
    // inline code, code block
    var codeColor: Color = Color.primary
    var blockQuoteColor: Color = Color.primary
    var listColor: Color = Color.primary
    var linkColor: Color = Color.primary

    
    var enableBackground: Bool = true
    var enableHeadingFont: Bool = true
    var enableBlockQuoteFont: Bool = true
    
    
}

extension Theme {
    
    var defaultCanvasColor: Color {
        switch appearanceType {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        }
    }
    
    var getBackgroundColor: Color {
        enableBackground ? canvasColor : defaultCanvasColor
    }
    
    
}

extension Theme: Equatable {
    
}
