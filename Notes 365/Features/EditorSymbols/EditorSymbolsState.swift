//
//  EditorSymbolState.swift
//  Notes 365
//
//  Created by kiran ipc on 24/08/23.
//

import SwiftUI

public struct EditorSymbolDoc: Identifiable {
    public let id: UUID = UUID()
    let heading: String
    let content: String
}


class EditorSymbolsState: ObservableObject {
    
    @Published var theme: MarkdownTheme = ThemeState.shared.theme
    @Published var editorType = EditorType.markdown
    
    var symbolsList = [EditorSymbolDoc]()
    
    init() {
        
        symbolsList.append(prepareBoldSymbols())
        symbolsList.append(prepareItalicSymbols())
        symbolsList.append(prepareStrikethroughSymbols())
        
        symbolsList.append(prepareHeadingSymbols())
        
        symbolsList.append(prepareOrderedListSymbols())
        symbolsList.append(prepareDashedListSymbols())
        
        symbolsList.append(prepareInlineCodeSymbols())
        symbolsList.append(prepareCodeBlockSymbols())
        
        symbolsList.append(prepareBlockQuoteSymbols())
    }
    
    func prepareBoldSymbols() -> EditorSymbolDoc {
        
        let heading = "Bold"
        let content = """
        This is **bold**
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareItalicSymbols() -> EditorSymbolDoc {
        
        let heading = "Italic"
        let content = """
        This is *italic*
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareStrikethroughSymbols() -> EditorSymbolDoc {
        
        let heading = "Strikethrough"
        let content = """
        This is ~~strikethrough~~
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareHeadingSymbols() -> EditorSymbolDoc {
        
        let heading = "Headings"
        let content = """
        # Heading 1
        ## Heading 2
        ### Heading 3
        #### Heading 4
        ##### Heading 5
        ###### Heading 6
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareOrderedListSymbols() -> EditorSymbolDoc {
        
        let heading = "Ordered List"
        let content = """
        1. Monday
        2. Tuesday
        3. Wednesday
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareDashedListSymbols() -> EditorSymbolDoc {
        
        let heading = "Dashed List"
        let content = """
        - macOS
        - iPadOS
        - iOS
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareInlineCodeSymbols() -> EditorSymbolDoc {
        
        let heading = "Inline code"
        let content = """
        this is `inline`
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareCodeBlockSymbols() -> EditorSymbolDoc {
        
        let heading = "Code Block"
        let content = """
        ```
        // line 1
        // line 2
        ```
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
    func prepareBlockQuoteSymbols() -> EditorSymbolDoc {
        
        let heading = "Block Quote"
        let content = """
        >Curabitur blandit tempus porttitor. Nullam quis risus eget urna mollis ornare vel eu leo.
        """
        return EditorSymbolDoc(heading: heading, content: content)
    }
    
}
