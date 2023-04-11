//
//  NamedColor.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/08/22.
//

import SwiftUI


struct NamedColor {
    
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(hex: Int) {
        self.red = Double((hex & 0xff0000) >> 16) / 255.0
        self.green = Double((hex & 0xff00) >> 8) / 255.0
        self.blue = Double((hex & 0xff) >> 0) / 255.0
    }
    
    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
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
