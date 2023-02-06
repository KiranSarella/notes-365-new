//
//  NamedColor.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/08/22.
//

import SwiftUI


struct NamedColor {
    
    let colorName: String
    let listName: String
    
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
    
    var color: Color {
        if listName.lowercased() == "Dynamic".lowercased() {
            
            if colorName.lowercased() == "Secondary".lowercased() {
                return Color.secondary
            } else {
                return Color.primary
            }
            
            //            return Color(colorName)
        } else if listName.lowercased() == "System".lowercased() {
            return NamedSystemColor(rawValue: colorName.lowercased())!.color
        } else {
            
            #if os(macOS)
            func getColorsList(name: String) -> NSColorList? {
                return NSColorList.availableColorLists.first { colorList in
                    colorList.name?.lowercased() == name.lowercased()
                }
            }
            
            guard let colorsList = getColorsList(name: listName) else { return Color.primary }
            return Color(colorsList.color(withKey: colorName)!)
            #elseif os(iOS)
            return Color.primary
            #endif
        }
    }
    
    func getColor() -> Color {
        return Color(red: red, green: green, blue: blue)
    }
    
    mutating func assignColor(component: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat)) {
        red = component.red
        green = component.green
        blue = component.blue
    }
}

extension NamedColor: Codable, Hashable { }
