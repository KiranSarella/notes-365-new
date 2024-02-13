//
//  ReadonlyCache.swift
//  Notes 365
//
//  Created by kiran ipc on 25/08/23.
//

import Foundation
import Combine


public struct ReadonlyEditorCache: Identifiable {
    public let id: UUID = UUID()
    let heading: String
    var content: String
    // UI optimazation related
    var editorView: UIEditorView = UIEditorView()
    var height: CGFloat = 0
    var isConfigured = false
    var themeID: UUID = UUID()
    var width: CGFloat = 0
}

extension ReadonlyEditorCache: Equatable {
    
}

extension ReadonlyEditorCache {

    var isRefreshRequired: Bool {
        (themeID != editorView.theme.id) || (width != editorView.textView.intrinsicContentSize.width)
    }
}
