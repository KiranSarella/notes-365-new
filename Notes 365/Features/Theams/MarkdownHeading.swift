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
        return "Heading \(self.rawValue)"
    }
    
    var fontSize: CGFloat {
        getHeadingFontSize()
    }
    
    var fontSizePercent: CGFloat {
        
        /*
         https://stackoverflow.com/questions/2325850/h1-h6-font-sizes-in-html
         
         h1: 2em
         h2: 1.5em
         h3: 1.17em
         h4: 1em
         h5: 0.83em
         h6: 0.67em
         */
        
        switch self {
        case .h1:
            return 2
        case .h2:
            return 1.5
        case .h3:
            return 1.17
        case .h4:
            return 1
        case .h5:
            return 0.83
        case .h6:
            return 0.67
        }
    }
    
    func getHeadingFontSize(baseFontSize: CGFloat = 14) -> CGFloat {
        
        return self.fontSizePercent * baseFontSize
    }
}
