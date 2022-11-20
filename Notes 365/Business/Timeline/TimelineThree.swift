//
//  TimelineThree.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


public struct TimelineThree: Identifiable {
    public let id: UUID = UUID()
    var fileUUID: UUID
    var fileName: String
    var filePath: String
    var content: String?
    var attriburedString: AttributedString?
    var needUpdate = true
    var isNotebookExists = true
}

extension TimelineThree: Equatable {
    
}

extension TimelineThree {
    
    mutating func updateWithTheme(theme: MarkdownTheme) async {
        
        // generate attribured string
        let markdownAttrStr = MarkdownAttriburedString(theme: theme)
        let newAttS = markdownAttrStr.getAttriburedString(forMarkdown: self.content!)
        self.attriburedString = AttributedString(newAttS)
    }
    
}
