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
    var fontName: String = ""
    var fontSize: Float = 16
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
}
