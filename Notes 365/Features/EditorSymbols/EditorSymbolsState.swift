//
//  EditorSymbolState.swift
//  Notes 365
//
//  Created by kiran ipc on 24/08/23.
//

import SwiftUI

//public struct ReadonlyEditorCache: Identifiable {
//    public let id: UUID = UUID()
//    let heading: String
//    let content: String
//}

@Observable
class EditorSymbolsState {
    var symbolsList = [ReadonlyEditorCache]()
    init() {
        symbolsList.append(prepareBoldSymbols())
        symbolsList.append(prepareItalicSymbols())
        symbolsList.append(prepareBoldAndItalicSymbols())
        symbolsList.append(prepareStrikethroughSymbols())
        symbolsList.append(prepareHeadingSymbols())
        symbolsList.append(prepareOrderedListSymbols())
        symbolsList.append(prepareDashedListSymbols())
        symbolsList.append(prepareHighlightSymbols())
        symbolsList.append(prepareInlineCodeSymbols())
        symbolsList.append(prepareCodeBlockSymbols())
        symbolsList.append(prepareBlockQuoteSymbols())
    }
    
    func prepareBoldSymbols() -> ReadonlyEditorCache {
        let heading = "Bold"
        let content = """
        This is **bold**
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareItalicSymbols() -> ReadonlyEditorCache {
        let heading = "Italic"
        let content = """
        This is *italic*
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareBoldAndItalicSymbols() -> ReadonlyEditorCache {
        let heading = "Bold & Italic"
        let content = """
        This is ***Bold & italic***
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareStrikethroughSymbols() -> ReadonlyEditorCache {
        let heading = "Strikethrough"
        let content = """
        This is ~~strikethrough~~
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareHeadingSymbols() -> ReadonlyEditorCache {
        let heading = "Headings"
        let content = """
        # Title
        ## Subtitle
        ### Heading
        #### Subheading
        """

        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareOrderedListSymbols() -> ReadonlyEditorCache {
        let heading = "Ordered List"
        let content = """
        1. Monday
        2. Tuesday
        3. Wednesday
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareDashedListSymbols() -> ReadonlyEditorCache {
        let heading = "Dashed List"
        let content = """
        - macOS
        - iPadOS
        - iOS
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareHighlightSymbols() -> ReadonlyEditorCache {
        let heading = "Highlight"
        let content = """
        This is ==highlight==
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareInlineCodeSymbols() -> ReadonlyEditorCache {
        let heading = "Inline code"
        let content = """
        this is `inline`
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareCodeBlockSymbols() -> ReadonlyEditorCache {
        let heading = "Code Block"
        let content = """
        ```
        // line 1
        // line 2
        ```
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
    func prepareBlockQuoteSymbols() -> ReadonlyEditorCache {
        let heading = "Block Quote"
        let content = """
        > Curabitur blandit tempus porttitor. Nullam quis risus eget urna mollis ornare vel eu leo.
        """
        return ReadonlyEditorCache(heading: heading, content: content)
    }
    
}
