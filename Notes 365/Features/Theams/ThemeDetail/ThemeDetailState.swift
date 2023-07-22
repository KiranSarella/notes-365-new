//
//  ThemeDetailState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 06/02/23.
//

import SwiftUI

@Observable
class ThemeDetailState {
    
    var theme: MarkdownTheme! = MarkdownTheme(id: UUID())
    
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
    
    init() {
        
    }
    
    func populateFields() {
        fontName = theme.fontName
        fontSize = Int(theme.fontSize)
        font = Font.custom(fontName, size: CGFloat(fontSize))
        
        bodyColor = theme.bodyColor.getColor()
        headingColor = theme.headingColor.getColor()
        boldColor = theme.styleColor.getColor()
        listColor = theme.listColor.getColor()
        codeColor = theme.codeColor.getColor()
        quoteColor = theme.blockQuoteColor.getColor()
    }
    
    func updateChanges() {
        theme.fontName = fontName
        theme.fontSize = Float(fontSize)
        theme.bodyColor.assignColor(component: bodyColor.components)
        theme.headingColor.assignColor(component: headingColor.components)
        theme.styleColor.assignColor(component: boldColor.components)
        theme.listColor.assignColor(component: listColor.components)
        theme.codeColor.assignColor(component: codeColor.components)
        theme.blockQuoteColor.assignColor(component: quoteColor.components)
    }
 
    func reset(with theme: MarkdownTheme) {
        fontName = theme.fontName
        fontSize = Int(theme.fontSize)
        font = Font.custom(fontName, size: CGFloat(fontSize))
        
        bodyColor = theme.bodyColor.getColor()
        headingColor = theme.headingColor.getColor()
        boldColor = theme.styleColor.getColor()
        listColor = theme.listColor.getColor()
        codeColor = theme.codeColor.getColor()
        quoteColor = theme.blockQuoteColor.getColor()
    }
    
    func resetTheme() {
        
        if theme.themeName == "Basic-light" {
            reset(with: ThemeBusiness.generateBasicLightTheme())
        } else if theme.themeName == "Basic-dark" {
            reset(with: ThemeBusiness.generateBasicDarkTheme())
        } else if theme.themeName == "Customized-light" {
            reset(with: ThemeBusiness.generateCustomizedLightTheme())
        } else if theme.themeName == "Customized-dark" {
            reset(with: ThemeBusiness.generateCustomizedDarkTheme())
        }
    }
    
}
