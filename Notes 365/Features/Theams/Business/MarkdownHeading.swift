//
//  MarkdownHeading.swift
//  Notes 365
//
//  Created by Kiran Sarella on 25/11/22.
//

import Foundation

let headingsScaleSize: CGFloat = 1.0

enum MarkdownHeading: Int, CaseIterable {
    case h1 = 1
    case h2 = 2
    case h3 = 3
    case h4 = 4
    
//    var shortTitle: String {
//        switch self {
//        case .h1:
//            return "Large Title"
//        case .h2:
//            return "Title"
//        case .h3:
//            return "Heading"
//        case .h4:
//            return "Subheading"
//        }
//    }
    
    var title: String {
        switch self {
        case .h1:
            return "Large Title"
        case .h2:
            return "Title"
        case .h3:
            return "Heading"
        case .h4:
            return "Subheading"
        }
    }
    
    var fontSize: CGFloat {
        getHeadingFontSize()
    }
    
    var sizePercent: CGFloat {
        switch self {
        case .h1:
            return 2.4
        case .h2:
            return 1.6
        case .h3:
            return 1.1
        case .h4:
            return 0.80
        }
    }
    
    var fontSizePercent: CGFloat {
        return sizePercent * headingsScaleSize
    }
    
    func getHeadingFontSize(baseFontSize: CGFloat = 14) -> CGFloat {
        self.fontSizePercent * baseFontSize
    }
    
    
}
