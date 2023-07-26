//
//  NamedColor.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/08/22.
//

import SwiftUI
import Observation

@Observable
struct NamedColor {
    
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0

    var color: Color = Color.black
    
    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        
        observeColorChanges()
        
        color = getColor()
    }
    
    init(hex: Int) {
        self.red = Double((hex & 0xff0000) >> 16) / 255.0
        self.green = Double((hex & 0xff00) >> 8) / 255.0
        self.blue = Double((hex & 0xff) >> 0) / 255.0
        
        observeColorChanges()
        color = getColor()
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
    
    func observeColorChanges() {
       
//        withObservationTracking {
//            color
//        } onChange: {
//            print(color.components)
////            assignColor(component: color.components)
//        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        red = try container.decode(Double.self, forKey: .red)
        green = try container.decode(Double.self, forKey: .green)
        blue = try container.decode(Double.self, forKey: .blue)
        
        color = getColor()
    }
    
    init?(rawValue: String) {
        
        if rawValue.isEmpty {
            return
        }
        
        let decoder = JSONDecoder()
        let obj = try! decoder.decode(NamedColor.self, from: rawValue.data(using: .utf8)!)

        red = obj.red
        green = obj.green
        blue = obj.blue
        
        color = getColor()
    }
    
    
}

extension NamedColor: Codable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
    }
    
    static func == (lhs: NamedColor, rhs: NamedColor) -> Bool {
        lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
    
    enum CodingKeys: CodingKey {
        case red
        case green
        case blue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
    }
}
