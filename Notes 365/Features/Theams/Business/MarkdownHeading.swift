//
//  MarkdownHeading.swift
//  Notes 365
//
//  Created by Kiran Sarella on 25/11/22.
//

import Foundation

enum MarkdownHeading: Int, CaseIterable {
    case h1 = 1
    case h2 = 2
    case h3 = 3
    case h4 = 4
    case h5 = 5
    case h6 = 6
    
    var title: String {
        switch self {
        case .h1:
            return "Large Title"
        case .h2:
            return "Title"
        case .h3:
            return "Title 2"
        case .h4:
            return "Title 3"
        case .h5:
            return "Heading"
        case .h6:
            return "Subheading"
        }
    }
    
    var fontSize: CGFloat {
        getHeadingFontSize()
    }
    
    var fontSizePercent: CGFloat {
        switch self {
        case .h1:
            return 3.0
        case .h2:
            return 2.5
        case .h3:
            return 2
        case .h4:
            return 1.5
        case .h5:
            return 1.1
        case .h6:
            return 0.83
        }
    }
    
    func getHeadingFontSize(baseFontSize: CGFloat = 14) -> CGFloat {
        self.fontSizePercent * baseFontSize
    }
}
