//
//  File.swift
//  Notes 365
//
//  Created by kiran ipc on 25/03/24.
//

import Foundation

@Observable
class SmartEditorViewState {
    var headings = [ContentItem]()
    var headingSelection: ContentItem.ID? = nil
    var headingsRange = Set<HeadingRange>()
    
}

