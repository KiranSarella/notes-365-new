//
//  PlistDocument.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/02/23.
//

import UIKit

class PlistDocument: UIDocument {
    
    var content = Data()
    
    func setContentChanges(newContent: Data) {
        content = newContent
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return content
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            content = data
        }
    }
    
    // MARK: - Errors
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        print(#function)
        print(error, userInteractionPermitted)
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
    }
}

