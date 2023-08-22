//
//  DayContentGenerator.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


struct DayContentGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Timeline
    var linesIterator: IndexingIterator<Array<String>>
    var today: Date
    var theme: MarkdownTheme
    
    init(lines: [String], today: Date, theme: MarkdownTheme) {
        // remove empty lines
        let lines = lines.map({ $0.count > 0 ? $0 : nil }).compactMap({ $0 })
        linesIterator = lines.makeIterator()
        self.today = today
        self.theme = theme
    }
    
    mutating func next() async -> Element? {
        
        if Task.isCancelled { return nil }
        
        if let line = linesIterator.next() {
            return await prepareContent(for: line)
        } else {
            return nil
        }
    }
    
    func makeAsyncIterator() -> DayContentGenerator {
        self
    }
    
    func prepareContent(for line: String) async -> Timeline? {
        
        let words = line.components(separatedBy: "\t")
        let uuid =  UUID(uuidString: words[0])!
        let fileName = words[2]
        let filePath = words[3]
        
        var timeline = Timeline(fileUUID: uuid, fileName: fileName, filePath: filePath)
        
//        // try to get dynamic notebook path if exists
//        if let dynamicFilePath = TimelineBusiness.shared.dynamicFolderPath(uuid: uuid) {
//            // file path
//            timeline.filePath = dynamicFilePath
//            // file name
//            if let dynamicFileName = dynamicFilePath.components(separatedBy: "/").last {
//                timeline.fileName = dynamicFileName
//            }
//            timeline.isNotebookExists = true
//        } else {
//            timeline.isNotebookExists = false
//        }
        // fetch content
        timeline.content = await TimelineBusiness(path: EnvironmentState.shared.basePathURL).readContent(today: today, fileName: timeline.fileUUID.uuidString)?.trimmingCharacters(in: .newlines) ?? "<no content>"
        // ?.trimmingCharacters(in: .newlines)
        
        if Task.isCancelled {
            return nil
        }
        // generate attribured string
        let markdownAttrStr = MarkdownAttriburedString(theme: theme)
        let newAttS = await markdownAttrStr.getAttriburedStringAsync(forMarkdown: timeline.content!)
        if Task.isCancelled {
            return nil
        }
        timeline.attriburedString = AttributedString(newAttS)
        
        return timeline
    }
}
