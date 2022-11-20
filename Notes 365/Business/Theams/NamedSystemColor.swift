//
//  NamedSystemColor.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/08/22.
//

import SwiftUI


enum NamedSystemColor: String, CaseIterable {
    
    // ref: https://developer.apple.com/design/human-interface-guidelines/foundations/color/
    case red
    case orange
    case yellow
    
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    
    case purple
    case pink
    
    case brown
    case gray
    
    case black
    case white
    
    
    var color: Color {
        switch self {
        case .green:
            return .green
        case .red:
            return .red
        case .purple:
            return .purple
        case .black:
            return .black
        case .blue:
            return .blue
        case .brown:
            return .brown
        case .cyan:
            return .cyan
        case .gray:
            return .gray
        case .indigo:
            return .indigo
        case .mint:
            return .mint
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .teal:
            return .teal
        case .white:
            return .white
        case .yellow:
            return .yellow
        }
    }
}


