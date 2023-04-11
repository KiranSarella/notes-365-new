//
//  PlistDocument.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/02/23.
//

import UIKit

class PlistDocument: UIDocument {
    
    var content = Data()
    
    var newContentAvailalble: (()->())?
    
    func setContentChanges(newContent: Data) {
        print(#function)
        content = newContent
    }
    
    override func contents(forType typeName: String) throws -> Any {
        print(#function)
        return content
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        print(#function)
        if let data = contents as? Data {
            content = data
            newContentAvailalble?()
        }
    }
    
    // MARK: - Errors
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        print(#function)
        print(error, userInteractionPermitted)
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
    }
}

