//
//  NoteDocument.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/02/23.
//

import UIKit

class MarkdownDocument: UIDocument {
    
    var content: String = ""
    
    var newContentAvailalble: (()->())?
    
    func setContentChanges(newContent: String) {
        content = newContent
    }
    
    // MARK: - write
    override func contents(forType typeName: String) throws -> Any {
//        print(#function)
        let data = content.data(using: .utf8)!
        return data
    }
    
    // MARK: - read
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
//        print(#function)
        if let data = contents as? Data {
            content = String(data: data, encoding: .utf8) ?? ""
//            print(content)
            newContentAvailalble?()
        }
    }
    
    // MARK: - Errors
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
//        print(#function)
        print(error, userInteractionPermitted)
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
    }
}
