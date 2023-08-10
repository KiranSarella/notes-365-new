//
//  EditorView.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//
import UIKit
// tree sitter parser
import SwiftTreeSitter
// markdown grammer
import TreeSitterMarkdown
import TreeSitterMarkdownInline


public class EditorView: UIView {
    
    var fileName: String = ""
    
    var text: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    var theme: MarkdownTheme = ThemeBusiness.generateBasicLightTheme()
    
    var editorType = EditorType.smart {
        didSet {
            switch editorType {
            case .smart:
                switchToSmartEditorMode()
            case .markdown:
                switchToMarkdownEditorMode()
            }
        }
    }
    
    public private(set) lazy var textStorage = NSTextStorage()
    
//    public private(set) lazy var smartTextStorage = SmartTextStorage()
//    public private(set) lazy var markdownStorage = MarkdownTextStorage()
    
    public private(set) lazy var layoutManager = NSLayoutManager()
//    private lazy var smartLayoutManagerDelegate = SmartLayoutManagerDelegate(textView: textView)
//    private lazy var markdownlayoutManagerDelegate = MarkdownLayoutManagerDelegate(textView: textView)
    
    public private(set) lazy var textContainer = NSTextContainer()
    public private(set) var textView: UITextView!
    public private(set) lazy var scrollview = UIScrollView()
    
    
    let parserBlock = Parser()
    let parserInline = Parser()
    var treeBlock:Tree? = nil
    var treeInline:Tree? = nil
    
    var preEditEndLocation = 0
    
    
//    func resetText(text: String) {
//
//        textStorage.setAttributedString(NSAttributedString(string: text))
//    }
    
    
    
    func setupTextViewStack() {
        
        self.layoutManager.textStorage = textStorage
        self.layoutManager.addTextContainer(self.textContainer)
        
        // create textView with container
        textView = UITextView(frame: self.bounds, textContainer: textContainer)
        textView.delegate = self
        
        // add textView to scrollView
        textView.translatesAutoresizingMaskIntoConstraints = false
        // add scroll view to Base View
        addSubview(textView)
//        textView.backgroundColor = .green
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: self.widthAnchor),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
    }
    
   
    convenience init(theme: MarkdownTheme) {
        
        self.init(frame: CGRect.zero)
        self.theme = theme
        
//        self.backgroundColor = UIColor.orange
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupTextViewStack()
        configureTextView()
        setupNewEditor()
    }

    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setupTextViewStack()
        configureTextView()
        setupNewEditor()
    }
    
}


extension EditorView {
    
    /**
     Creates and configures the NSTextView, NSTextContainer, NSTextStorage and NSLayoutManager objects
     - parameter isHorizontalScrollingEnabled: If true, the NSTextView will allow horizontal scrolling
     */
    
    func configureTextContainer() {
        
        textContainer.lineFragmentPadding = 20  // margin padding
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        self.layoutManager.addTextContainer(self.textContainer)
        
//        let contentSize = self.scrollview.contentSize
//        self.textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        self.textContainer.widthTracksTextView = true
    }
    
    internal func configureTextView() {
        // TextView -> TextContainer -> LayoutManager -> TextStorage
        
        configureTextContainer()
        
        let contentSize = self.scrollview.contentSize
        
//        self.textView.minSize = CGSize(width: 0, height: 0)
//        self.textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
//        self.textView.isVerticallyResizable = true
//        self.textView.isHorizontallyResizable = false
        self.textView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        
//        textView.autoresizingMask = [.width]
        
        self.textView.isFindInteractionEnabled = true
        
        
//        self.textView
//        self.textView.allowsUndo = true
//        self.textView.usesFindPanel = true
//        self.textView.usesFindBar = true
//        self.textView.showFindIndicator(for: NSRange(location: 20, length: 200))
//        self.textView.usesRuler = true
        
//        self.textView.backgroundColor = UIColor.magenta
        

        
        let languageBlock = Language(language: tree_sitter_markdown())
        let languageInline = Language(language: tree_sitter_markdown_inline())
        
        try? parserBlock.setLanguage(languageBlock)
        try? parserInline.setLanguage(languageInline)
    }
 
    
    func refreshLayout() {
        
//        textContainer.replaceLayoutManager(layoutManager)
        
        self.layoutManager.invalidateDisplay(forCharacterRange: NSRange())
    }
    
    // storage
    func setupNewEditor() {
        
//        self.layoutManager.textStorage = textStorage
        // replaceTextStorage(textStorage)  // this is imp. routne assign will not work
        self.layoutManager.textStorage?.delegate = self
//        self.layoutManager.delegate =  smartLayoutManagerDelegate
    }
    
    
//    func setupSmartEditor() {
//
//        smartTextStorage = SmartTextStorage(str: self.textView.string)  // this is imp.
//
//        self.layoutManager.delegate =  smartLayoutManagerDelegate
//
//        // refresh
//        self.layoutManager.replaceTextStorage(smartTextStorage)
//        refreshLayout()
//
//        // old storage to new storage
//        self.textView.string = self.textView.string // other wise getting odd font related behaviour
//    }
    
    
    func switchToSmartEditorMode() {
        
        layoutManager.delegate =  self
        textContainer.replaceLayoutManager(layoutManager)
        
//        // scroll to cursor rect
//        if let cursorRange = textView.selectedRanges.first?.rangeValue {
//            textView.scrollRangeToVisible(cursorRange)
//        }
    }
    
    func switchToMarkdownEditorMode() {
        
        layoutManager.delegate = nil
        textContainer.replaceLayoutManager(layoutManager)
        
//        // scroll to cursor rect
//        if let cursorRange = textView.selectedRanges.first?.rangeValue {
//            textView.scrollRangeToVisible(cursorRange)
//        }
    }
}


// auto formatting
extension EditorView {
    
    
    
}


// text view delegate

extension EditorView: UITextViewDelegate {
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
    
    }
}

extension EditorView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        var extendedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)
    }
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {

        
        
        guard
            let treeBlock = treeBlock,
            let treeInline = treeInline
        else {
            // do initial parsing
            // block parsing
            initialBlockParser(textStorage: textStorage)
            // inline parsing
            initialInlineParser(textStorage: textStorage)
            return
        }
        
        /// let edit = InputEdit(startByte: editStartByteOffset,
        ///                      oldEndByte: preEditEndByteOffset,
        ///                      newEndByte: postEditEndByteOffset,
        ///                      startPoint: editStartPoint,
        ///                      oldEndPoint: preEditEndPoint,
        ///                      newEndPoint: postEditEndPoint)
        
//        let newEndLocation = NSMaxRange(editedRange) + delta
        
//        let edit = InputEdit(startByte: UInt32(editedRange.location * 2),
//                  oldEndByte: UInt32(preEditEndLocation * 2),
//                  newEndByte: UInt32(newEndLocation * 2),
//                  startPoint: Point.zero,
//                  oldEndPoint: Point.zero,
//                  newEndPoint: Point.zero)
        
        guard let edit = InputEdit(range: editedRange, delta: delta, oldEndPoint: .zero) else { return }
        print(edit)
        
        treeBlock.edit(edit)
        treeInline.edit(edit)
        
//        resetAttributes(textStorage: textStorage, extendedRange: node.range)
        
        // block parsing
        blockParser(textStorage: textStorage)
        // inline parsing
        inlineParser(textStorage: textStorage)
        
        /*
        guard let newTree = parser.parse(tree: tree, string: text) else { return }

        let changedRanges = tree.changedRanges(from: newTree)

        print("changes: ", changedRanges.count)

        // clear all attribures
        let fullRange = textStorage.fullRange()
        if fullRange.length > 0 {
//            textStorage.removeAttribute(.foregroundColor, range: fullRange)
//            textStorage.setAttributes([:], range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: UIColor.black, range: fullRange)
        }
        
        for changedRange in changedRanges {
            print(changedRange)
            
            newTree.enumerateNodes(in: changedRange.bytes) { node in
//                print(node, node.range, node.nodeType!, node.byteRange, node.isNamed)
                
                textStorage.addAttribute(.foregroundColor, value: UIColor.red, range: node.range)
            }
            
//            let nsrange = NSRange(location: changedRange.bytes.lowerBound, length: changedRange.bytes.count)
//            print(nsrange)
//
            
            
//            let start = text.index(text.startIndex, offsetBy: Int(changedRange.bytes.lowerBound / 2))
//            let end = text.index(text.startIndex, offsetBy: Int(changedRange.bytes.upperBound / 2))
//            let subString = text[start..<end]
//            print(subString)
        }
     
//        preEditEndLocation = newEndLocation
        self.tree = newTree
         
         */
    }

    // MAKR: - Tree-sitter
    
    func initialBlockParser(textStorage: NSTextStorage) {
        print(#function)
        guard let newTree = parserBlock.parse(text) else { return }
        
        guard let range = newTree.rootNode?.byteRange else { return }
        
        newTree.enumerateNodes(in: range) { node in
            applyBlockStyles(node: node, attrStr: textStorage)
        }
        
        self.treeBlock = newTree
    }
    
    func initialInlineParser(textStorage: NSTextStorage) {
        print(#function)
        guard let newTree = parserInline.parse(text) else { return }
        
        guard let range = newTree.rootNode?.byteRange else { return }
        
        newTree.enumerateNodes(in: range) { node in
            applyInlineStyles(node: node, attrStr: textStorage)
        }
        
        self.treeInline = newTree
    }
    
    func blockParser(textStorage: NSTextStorage) {
        print(#function)
        guard let newTree = parserBlock.parse(text) else { return }
        guard let treeBlock = treeBlock else { return }
        
        let changedRanges = treeBlock.changedRanges(from: newTree)
        print("changes: ", changedRanges.count)

        for changedRange in changedRanges {
            print(changedRange)
            
            newTree.enumerateNodes(in: changedRange.bytes) { node in
                applyBlockStyles(node: node, attrStr: textStorage)
            }
        }
        
        self.treeBlock = newTree
    }
    
    func inlineParser(textStorage: NSTextStorage) {
        print(#function)
        guard let newTree = parserInline.parse(text) else { return }
        guard let treeInline = treeInline else { return }
        
        let changedRanges = treeInline.changedRanges(from: newTree)
        print("changes: ", changedRanges.count)

        for changedRange in changedRanges {
            print(changedRange)
            
            newTree.enumerateNodes(in: changedRange.bytes) { node in
                applyInlineStyles(node: node, attrStr: textStorage)
            }
        }
        
        self.treeInline = newTree
    }
    
    func applyBlockStyles(node: Node, attrStr: NSTextStorage) {
        print(node.nodeType, node.byteRange)
        
//        resetAttributes(textStorage: attrStr, extendedRange: node.range)
        
        if node.nodeType! == "atx_heading" {
            print("")
            
            if let firstChild = node.firstChild {
                let heading = firstChild.nodeType
                
                var fontSize: CGFloat = 52
                
                if heading == "atx_h1_marker" {
                    fontSize = getHeadingFontSize(level: 1)
                }
                else if heading == "atx_h2_marker" {
                    fontSize = getHeadingFontSize(level: 2)
                }
                else if heading == "atx_h3_marker" {
                    fontSize = getHeadingFontSize(level: 3)
                }
                else if heading == "atx_h4_marker" {
                    fontSize = getHeadingFontSize(level: 4)
                }
                else if heading == "atx_h5_marker" {
                    fontSize = getHeadingFontSize(level: 5)
                }
                else if heading == "atx_h6_marker" {
                    fontSize = getHeadingFontSize(level: 6)
                }
                
                // bold
                var boldFont = theme.font
                if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitBold) {
                    boldFont = UIFont(descriptor: fontDesc, size: fontSize)
                }
                
                // font
                attrStr.addAttribute(.font, value: boldFont, range: node.range)
                // color
                attrStr.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: node.range)
//                // hide special chars
                let charRange = NSRange(location: firstChild.range.location, length: firstChild.range.length + 1)
                attrStr.addAttribute(NSAttributedString.Key.markdown,
                                                   value: 0,
                                                   range: charRange)
//                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .thin), range: NSRange(location: firstChild.range.location, length: firstChild.range.length + 1))
                
            }
            
            
        }
        
        else if node.nodeType! == "paragraph" {
            
                attrStr.addAttribute(.font, value: theme.font, range: node.range)
                attrStr.addAttribute(.foregroundColor, value: theme.bodyColor.uiColor, range: node.range)
        } else if node.nodeType! == "block_quote" {
            attrStr.addAttribute(.font, value: theme.font, range: node.range)
            attrStr.addAttribute(.foregroundColor, value: theme.blockQuoteColor.uiColor, range: node.range)
        } else if node.nodeType! == "block_quote_marker" {
//            attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .light), range: node.range)
            attrStr.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: node.range)
        } else if node.nodeType! == "list_marker_minus" || node.nodeType! == "list_marker_dot" {
            attrStr.addAttribute(.foregroundColor, value: theme.listColor.uiColor, range: node.range)
        } else if node.nodeType! == "fenced_code_block" {
            
            let font = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: .regular)
            
            attrStr.addAttribute(.font, value: font, range: node.range)
            attrStr.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: node.range)
            
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.alignment = .left
            
            attrStr.addAttribute(.paragraphStyle, value: paraStyle, range: node.range)
        } else {
            print("NO BLOCK CHANGE *****")
        }
    }
    
    func applyInlineStyles(node: Node, attrStr: NSTextStorage) {
        print(node.nodeType)
        
//        resetAttributes(textStorage: attrStr, extendedRange: node.range)
        
        if node.nodeType! == "emphasis" {
            
            var italicFont = theme.font
            
            if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitItalic) {
                italicFont = UIFont(descriptor: fontDesc, size: CGFloat(theme.fontSize))
            }
            
            attrStr.addAttribute(.font, value: italicFont, range: node.range)
            attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
        } else if node.nodeType! == "strong_emphasis" {
            var boldFont = theme.font
            if let fontDesc = theme.font.fontDescriptor.withSymbolicTraits(.traitBold) {
                boldFont = UIFont(descriptor: fontDesc, size: CGFloat(theme.fontSize))
            }
            
            // font
            attrStr.addAttribute(.font, value: boldFont, range: node.range)
            // color
            attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
        } else if node.nodeType! == "strikethrough" {
//                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 22), range: node.range)
            // foreground color
            attrStr.addAttribute(.foregroundColor, value: theme.styleColor.uiColor, range: node.range)
            // strikethroughStyle
            attrStr.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: node.range)
            // line color
            attrStr.addAttribute(.strikethroughColor, value: theme.styleColor.uiColor, range: node.range)
        } else if node.nodeType! == "code_span" {
            attrStr.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 22, weight: .regular), range: node.range)
            attrStr.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: node.range)
        } else if node.nodeType!.hasSuffix("delimiter") {
            
            attrStr.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: node.range)
            
//            attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 0.1, weight: .ultraLight), range: node.range)
//            attrStr.addAttribute(.foregroundColor, value: UIColor.clear, range: node.range)
        } else {
            print("NO INLINE CHANGE ******")
        }
//            else if node.isNamed == false {
//                attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 22, weight: .ultraLight), range: node.range)
//                attrStr.addAttribute(.foregroundColor, value: UIColor.gray, range: node.range)
//            }
        
    }
    
    
    func resetAttributes(textStorage: NSTextStorage, extendedRange: NSRange) {
        
        textStorage.removeAttribute(.markdown, range: extendedRange)
        textStorage.removeAttribute(.markdownRange, range: extendedRange)
        textStorage.removeAttribute(.foregroundColor, range: extendedRange)
//        textStorage.removeAttribute(.paragraphStyle, range: extendedRange)
        textStorage.removeAttribute(.underlineColor, range: extendedRange)
        textStorage.removeAttribute(.underlineStyle, range: extendedRange)
        
        textStorage.addAttribute(.markdownRange, value: MarkdownPattern.body, range: extendedRange)
    }
    
    
    public func textStorage333(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
     
//        print("editedRange", editedRange, "delta", delta, "editedMask", editedMask)
   
        var extendedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
//        textStorage.setAttributes([:], range: extendedRange)
        // FIXIT: - ** if enabled, telugu font will not work. if disabled, code block and below lines font issue.
//        textStorage.removeAttribute(.font, range: extendedRange)
        textStorage.removeAttribute(.markdown, range: extendedRange)
        textStorage.removeAttribute(.markdownRange, range: extendedRange)
        textStorage.removeAttribute(.foregroundColor, range: extendedRange)
//        textStorage.removeAttribute(.paragraphStyle, range: extendedRange)
        textStorage.removeAttribute(.underlineColor, range: extendedRange)
        textStorage.removeAttribute(.underlineStyle, range: extendedRange)
        
        textStorage.addAttribute(.markdownRange, value: MarkdownPattern.body, range: extendedRange)
        
        // FIXIT: - ** if enabled, telugu font will not work. if disabled, code block and below lines font
//        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)

        
//        let font = textStorage.attribute(.font, at: 0, effectiveRange: &extendedRange)
//        print(font)
////        textStorage.addAttribute(.font, value: theme.font, range: extendedRange)
//        let font2 = textStorage.attribute(.font, at: 0, effectiveRange: &extendedRange)
//        print(font2)
        
        
//        print("after:", bodyFont.fontDescriptor.symbolicTraits, extendedRange)
//
        textStorage.addAttribute(.foregroundColor, value: theme.bodyColor.uiColor, range: extendedRange)

        
//        textStorage.enumerateAttributes(in: extendedRange) { attribureKeys, range, pointer in
//            print(attribureKeys, range)
//        }
        
        // ** order by preferenced - low to high
        processBlockQuote(extendedRange: extendedRange, textStorage: textStorage)
        processHeadings(extendedRange: extendedRange, textStorage: textStorage)
        
        processOrderedList(extendedRange: extendedRange, textStorage: textStorage)
        processUnorderedList(extendedRange: extendedRange, textStorage: textStorage)
        processCheckList(extendedRange: extendedRange, textStorage: textStorage)
        
        processItalic(extendedRange: extendedRange, textStorage: textStorage)   // *
        processBold(extendedRange: extendedRange, textStorage: textStorage)     // **
        processBoldAndItalic(extendedRange: extendedRange, textStorage: textStorage)    // ***
        processStrikethrough(extendedRange: extendedRange, textStorage: textStorage)
//        processLink(extendedRange: extendedRange, textStorage: textStorage)
        
        
        processInlineCode(extendedRange: extendedRange, textStorage: textStorage)
        
        processHttp(extendedRange: extendedRange, textStorage: textStorage)
        
        let fullRange = textStorage.fullRange()
        if fullRange.length > 0 {
            processCodeBlock(extendedRange: textStorage.fullRange(), textStorage: textStorage)
        }
        
        
        
        
        // treat non `.markdownRange` as body
        
        
        
//        textStorage.enumerateAttribute(.markdownRange, in: extendedRange, options: []) { value, range, stop in
//            guard let markdownPattern = value as? MarkdownPattern else { return }
//
//            /*
//             case 1: ignore unknown font family types
//             case 2: apply to remaining types
//             */
//
////            let subAttrStr = textStorage.attributedSubstring(from: range)
////            subAttrStr.string.contains(CharacterSet.alphanumerics)
//
//            if markdownPattern == .body {
//
//                textStorage.enumerateAttribute(.font, in: range) { value, range, stop in
//
//                    guard let font = value as? UIFont else { return }
//
//                    if font.fontName.contains(theme.bodyFontName) ||
//                        font.fontName.contains(theme.codeFontName) ||
//                        font.fontName.contains(theme.blockQuoteFontName) ||
//                        font.fontName.contains(theme.headingFontName)
//                    {
//                        let bodyFont = UIFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
//
//                        textStorage.addAttribute(.font, value: bodyFont, range: range)
//                    }
//                }
//            }
//
//
//
//
//
//
//            //            fontDescriptor = fontDescriptor.withFamily(bodyFont.familyName!)
//            //            print(bodyFont.familyName!)
//
//            //            fontDescriptor = fontDescriptor.withFamily(bodyFont?.familyName ?? UIFont.systemFont(ofSize: 14).familyName!)
//            //            fontDescriptor = fontDescriptor.withFamily(UIFont.systemFont(ofSize: 14).familyName!)
//
//            //            let newFont = UIFont(descriptor: fontDescriptor, size: CGFloat(theme.bodyFontSize))!
//            //
//            ////            let newFont = font.apply(newTraits: symbolicTraits, newPointSize: theme.bodyFontSize)
//            //            textStorage.addAttribute(.font, value: newFont, range: range)
//
//            //            print("after:", newFont.fontDescriptor.symbolicTraits, range)
//            //            print(newFont.fontDescriptor)
//            //
//            //            let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 1))
//            //            innerAttributedString.addAttribute(.font, value: newFont, range: range)
//            //            textStorage.addAttribute(.foregroundColor, value: UIColor.textColor, range: range)
//        }
        
        
    }
    
    
    
    
   
  
}


// MARK: - process markdown chars
extension EditorView {
    
    func processBold(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.bold.rawValue
        
//        var boldFont = theme.font
//        boldFont = boldFont.apply(newTraits: .bold)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            
            let regExCharLenght = 2
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                // foreground color
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            
//            innerAttributedString.addAttribute(.font,
//                                               value: boldFont,
//                                               range: styleRange)
            
            // update text color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // get markdown symbol start,end ranges
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // mark char as markdown start symbol, used to show/hide in layout delegate
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)
            
            // mark char as markdown end symbol, used to show/hide in layout delegate
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: endRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "bold"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.bold, range: match!.range)
        }
    }
    
    
    
    func processItalic(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.italic.rawValue
        
//        var italicFont = theme.font
//        italicFont = italicFont.apply(newTraits: .italic)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
//            // font
//            innerAttributedString.addAttribute(.font,
//                                                    value: italicFont,
//                                                    range: styleRange)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits(.traitItalic) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
//                (  .apply(newTraits: .italicTrait)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // markdown
            let regExCharLenght = 1
            
            let markdownStartRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let markdownEndRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - padding, length: regExCharLenght)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.italic, range: match!.range)
        }
    }
    
    
    func processBoldAndItalic(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.boldAndItalic.rawValue
        
//        var italicFont = theme.font
//        italicFont = italicFont.apply(newTraits: [.italic, .bold])
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let padding = 0
            let styleRange = NSRange(location: match!.range.location, length: match!.range.length - padding)
            // font
//            innerAttributedString.addAttribute(.font,
//                                               value: italicFont,
//                                               range: styleRange)
            
            innerAttributedString.enumerateAttribute(.font, in: styleRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                let newFontDesc = font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) ?? font.fontDescriptor
                let newFont = UIFont(descriptor: newFontDesc, size: font.pointSize)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: theme.h1Color.uiColor, range: range)
            }
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.styleColor.uiColor, range: styleRange)
            
            // markdown
            let regExCharLenght = 3
            
            let markdownStartRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let markdownEndRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - padding, length: regExCharLenght)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: markdownStartRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: markdownEndRange)
            
            let info: [String: Any] = [
                "range": styleRange,
                "type": "italic"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.italic, range: match!.range)
        }
    }
    
    
    
    
//    func prepareRange(fullRange range: NSRange, formatLenght regExCharLenght: Int) -> (NSRange, NSRange) {
//
//        let regExCharLenght = 1
//
//        let markdownStartRange = NSRange(location: range.location, length: regExCharLenght)
//        let markdownEndRange = NSRange(location: range.location + range.length - regExCharLenght, length: regExCharLenght)
//
//        return (markdownStartRange, markdownEndRange)
//    }
    
   
    
    func processStrikethrough(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.strikethrough.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            // text color
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.styleColor.uiColor,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // strikethrough line
            innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // line color
            innerAttributedString.addAttribute(.strikethroughColor,
                                               value:  theme.styleColor.uiColor,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 2 , length: 2))
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location + 1, length: match!.range.length - 1),
                "type": "strikethrough"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location + 1, length: match!.range.length - 1))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.strikethrough, range: match!.range)
        }
    }
    
    func processHttp(extendedRange: NSRange, textStorage innerAttributedString: NSMutableAttributedString) {
        
        let pattern = MarkdownPattern.url

        
        var boldFont = theme.font
        //        let fontDesc = boldFont.fontDescriptor.withSymbolicTraits(.traitBold)
        //        boldFont = UIFont.boldSystemFont(ofSize: boldFont.pointSize)
        //        boldFont = boldFont.apply(newTraits: .bold)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        //        print(innerAttributedString.string.substring(with: extendedRange))
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let regExCharLenght = 0
            //            let frontPadding = 0
            let backPadding = 0
            let styleRange = NSRange(location: match!.range.location + regExCharLenght, length: match!.range.length - (2 * regExCharLenght) - backPadding)
            
            
            innerAttributedString.addAttribute(.font,
                                               value: boldFont,
                                               range: styleRange)
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.blockQuoteColor.uiColor, range: styleRange)
        }
    }
    
    
    func processLink(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.link.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
//            innerAttributedString.addAttribute(.foregroundColor,
//                                               value:  theme.linkColor.uiColor,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineStyle,
//                                                    value:  NSUnderlineStyle.single.rawValue,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineColor,
//                                                    value:  theme.linkColor.uiColor,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.link, value: NSURL(string: "http://notes365.app")!, range: match!.range)
            
            innerAttributedString.addAttribute(.strokeColor,
                                               value:  UIColor.red,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.foregroundColor,
                                               value:  UIColor.red,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineStyle,
                                                                value:  NSUnderlineStyle.single.rawValue,
                                                                range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineColor,
                                                           value:  UIColor.red,
                                                                range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "link"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
         
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.link, range: match!.range)
        }
    }
    
    
    func processInlineCode(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.inlineCode.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            let font = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: UIFont.Weight.medium)
            let textRange = NSRange(location: match!.range.location + 1, length: match!.range.length - 2)
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                               range: textRange)
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.codeColor.uiColor,
                                                    range: textRange)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 1))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location + match!.range.length - 1 , length: 1))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "inlinecode"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.inlineCode, range: match!.range)
        }
    }
    
    func canPocessCodeBlock(_ extendedRange: NSRange, _ innerAttributedString: NSTextStorage) -> (Int, Bool) {
        
        let pattern = MarkdownPattern.codeBlockBalanceChecker.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        let numberOfMatches = regex.numberOfMatches(in: innerAttributedString.string, range: extendedRange)
        print(numberOfMatches)
        if numberOfMatches == 0 {
            return (numberOfMatches, false)
        }
        
        return (numberOfMatches, numberOfMatches.isMultiple(of: 2))
        
//        return false
    }
    
    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        // continue if balanced only, else skip
        let (count, canProceed) = canPocessCodeBlock(extendedRange, textStorage)
        
        if canProceed == false {
            return
        }
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        // pairs count shoud match half of total single symbols
        let pairsCount = regex.numberOfMatches(in: innerAttributedString.string, range: extendedRange)
        print(pairsCount)
        if pairsCount != (count / 2) {
            return
        }
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let font = UIFont.monospacedSystemFont(ofSize: theme.font.pointSize, weight: UIFont.Weight.medium)
            let textRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 6)
            
            // remove all existing attributes
            innerAttributedString.setAttributes([:], range: textRange)
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                               range: textRange)
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.codeColor.uiColor,
                                               range: textRange)
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location, length: 3))
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: NSRange(location: match!.range.location + match!.range.length - 3 , length: 3))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "codeblock"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                               value: info,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.inlineCode, range: match!.range)
        }
    }
    
    func processOrderedList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.orderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(.font,
                                               value:  theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "orderedlist"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
        
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.orderedList, range: match!.range)
        }
        
    }
    
    
    func processUnorderedList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.unorderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value:  theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "unorderedlist"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.unorderedList, range: match!.range)
        }
    }
    
    func processCheckList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.checkList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(NSAttributedString.Key.font,
                                               value: theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value: theme.listColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "checkList"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
         
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.checkList, range: match!.range)
        }
    }
    
    
    
//    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
//
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        //        paragraphStyle.minimumLineHeight = 10
//        paragraphStyle.lineSpacing = 10
//
//        let globalBlock = NSTextBlock()
//        globalBlock.setWidth(140, type: .absoluteValueType, for: .padding, edge: .minX)
//        globalBlock.setContentWidth(100, type: .percentageValueType)
//
//        let paddingTextCodeBlock = NSTextBlock()
//        paddingTextCodeBlock.setContentWidth(80, type: .percentageValueType)
//        //        paddingTextCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
//        paddingTextCodeBlock.setBorderColor(.gray)
//        paddingTextCodeBlock.setWidth(1, type: .absoluteValueType, for: .border)
//        //        paddingTextCodeBlock.setWidth(20, type: .absoluteValueType, for: .padding, edge: .minX)
//        paddingTextCodeBlock.backgroundColor = UIColor.lightGray
//
//
//        let textCodeBlock = NSTextBlock()
//        textCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
//        textCodeBlock.backgroundColor = UIColor.lightGray
//        //        textCodeBlock.setWidth(20, type: .absoluteValueType, for: .margin)
//        textCodeBlock.setContentWidth(60, type: .percentageValueType)
//
//
//        //        let codeBlock = TweetTextBlock()
//
//        paragraphStyle.textBlocks = [globalBlock, paddingTextCodeBlock]
//
//        //        paragraphStyle.textBlocks = [codeBlock]
//
//        let pattern = MarkdownPattern.codeBlock.rawValue
//
//        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
//
//        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
//            match, flags, stop in
//
//            let range = NSRange(location: match!.range.location, length: match!.range.length)
//
//            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
//                guard let font = value as? UIFont else { return }
//                // bold
//                let newFont = font.apply(newTraits: .monoSpace, newPointSize: CGFloat(theme.font.pointSize - 2))
//                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                // foreground color
//                innerAttributedString.addAttribute(.foregroundColor, value: theme.codeColor.uiColor, range: range)
//            }
//
////            var font = UIFont(name: theme.codeFontName, size: CGFloat(theme.bodyFontSize - 2))
//////            font = font.apply(newTraits: .expanded)
////
////            innerAttributedString.addAttribute(.font,
////                                                    value:  font,
////                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
////
////            innerAttributedString.addAttribute(.foregroundColor,
////                                               value:  theme.codeBlockColor),
////                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//
//            let regExCharLenght = 3
//            let backPadding = 0
//            // markdown
//            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
//            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
//                                               value: 0,
//                                               range: startRange)
//
//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
//                                               value: 0,
//                                               range: endRange)
//
//
//
//            let info: [String: Any] = [
//                "range": NSRange(location: match!.range.location, length: match!.range.length),
//                "type": "codeblock"
//            ]
//            // info
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
//                                                    value: info,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//
//            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.codeBlock, range: match!.range)
//        }
//    }
    
    func processBlockQuote(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
  
        let pattern = MarkdownPattern.blockQuote.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let font =  theme.font
            
            innerAttributedString.addAttribute(.font,
                                               value: font,
                                                range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  theme.blockQuoteColor.uiColor,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 1))

//            // add id key
//            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
//                                                    value: 0,
//                                                    range: NSRange(location: match!.range.location + match!.range.length, length: 1))



            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "blockQuote"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))

            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.blockQuote, range: match!.range)
        }
    }
    
    func processHeadings(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.paragraphSpacingBefore = 15
        paragraphStyle.paragraphSpacing = 5
        //            paragraphStyle.lineSpacing = 5
        
        
        let patternH1 = MarkdownPattern.h1.rawValue
        
        let regex1a = try! NSRegularExpression(pattern: patternH1, options: [.anchorsMatchLines])
        
        regex1a.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let range = NSRange(location: match!.range.location + 2, length: match!.range.length - 2)
            
            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                // bold
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 1))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 2))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h1, range: match!.range)
        }
        
        
        
        let patternH2 = MarkdownPattern.h2.rawValue
        
        let regex2 = try! NSRegularExpression(pattern: patternH2, options: [.anchorsMatchLines])
        
        regex2.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 3, length: match!.range.length - 3)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 2))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 2)),
//                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemCyan,
//                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 3))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h2, range: match!.range)
        }
        
        
        let patternH3 = MarkdownPattern.h3.rawValue
        
        let regex3 = try! NSRegularExpression(pattern: patternH3, options: [.anchorsMatchLines])
        
        regex3.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 4, length: match!.range.length - 4)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 3))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 3)),
//                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemTeal,
//                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 4))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h3, range: match!.range)
        }
        
        
        let patternH4 = MarkdownPattern.h4.rawValue
        
        let regex4 = try! NSRegularExpression(pattern: patternH4, options: [.anchorsMatchLines])
        
        regex4.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 5, length: match!.range.length - 5)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 4))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 4)),
//                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemBrown,
//                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
            
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 5))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h4, range: match!.range)
        }
        
        
        let patternH5 = MarkdownPattern.h5.rawValue
        
        let regex5 = try! NSRegularExpression(pattern: patternH5, options: [.anchorsMatchLines])
        
        regex5.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 6, length: match!.range.length - 6)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 5))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 5)),
//                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemIndigo,
//                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 6))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h5, range: match!.range)
        }
        
        let patternH6 = MarkdownPattern.h6.rawValue
        
        let regex6 = try! NSRegularExpression(pattern: patternH6, options: [.anchorsMatchLines])
        
        regex6.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let charRange = NSRange(location: match!.range.location + 7, length: match!.range.length - 7)
            
            innerAttributedString.enumerateAttribute(.font, in: charRange, options: []) { value, range, stop in
                guard let font = value as? UIFont else { return }
                
                let fontDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
                let newFont = UIFont(descriptor: fontDesc ?? font.fontDescriptor, size: getHeadingFontSize(level: 6))
                
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: theme.headingColor.uiColor, range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: UIFont.boldSystemFont(ofSize: getHeadingFontSize(level: 6)),
//                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: UIColor.systemMint,
//                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//
            
            //            innerAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: match!.range)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                                    value: 0,
                                                    range: NSRange(location: match!.range.location, length: 7))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.h6, range: match!.range)
        }
    }
    
    
    func getHeadingFontSize(level: CGFloat) -> CGFloat {
        
        let heading = MarkdownHeading(rawValue: Int(level))!
        return heading.getHeadingFontSize(baseFontSize: theme.font.pointSize)
    }
}


extension EditorView: NSLayoutManagerDelegate {
    
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        
//        print(#function)
//
//        print(glyphRange)
//
//        print(textView.selectedRange)
//
//        let lineRange = (textStorage.string as NSString).lineRange(for: textView.selectedRange)
//        print("lineRange", lineRange)
////
//
//        print("NSIntersectsRect", NSIntersectionRange(glyphRange, lineRange))
//        print(glyphRange.intersection(textView.selectedRange))
//        print(textView.selectedRange.intersection(glyphRange))
//
//
//        let isIntersected = (glyphRange.intersection(lineRange)?.length ?? 0) > 0
//        print("is intersected: ", isIntersected)
        
//        if let info = textView.textStorage?.attribute(.markdownInfo, at: charIndexes.pointee, effectiveRange: nil) as? [String: Any] {
//            print(info)
//            if info["type"] as! String == "codeblock" {
//                return 0
//            }
//        }
//
        
        // Make mutableProperties an optional to allow checking if it gets allocated
        let controlCharProps: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = UnsafeMutablePointer(mutating: props)
        
//        if let attribute = textStorage.attribute(.markdown, at: charIndexes.pointee, effectiveRange: nil) as? Int, attribute == 0 {
//
//        }
//
        var mutableGlymphRange = glyphRange
        
        
        for index in 0..<glyphRange.length {
            
            let charPtr = charIndexes[index]
            

            
            var isMarkdown: Bool {
                let attrValue = textStorage.attribute(.markdown, at: charPtr, effectiveRange: &mutableGlymphRange)
                return attrValue != nil
            }
            
//            print("isMarkdown", isMarkdown)
            
            if isMarkdown {
                // hide symbol
                controlCharProps?[index] = .null
            }
            
//            let uniChar = (textStorage.string as NSString).character(at: charPtr)
//            if let unicodeScalar = UnicodeScalar(uniChar) {
//                print(Character(unicodeScalar))
////                if Character(unicodeScalar) == "*" {
////                    controlCharProps?[index] = .null
////                }
//            }
//            print(textStorage.attribute(.markdown, at: charIndexes[index], effectiveRange: nil))
            
//            if textStorage.attribute(.markdown, at: charIndexes[index], effectiveRange: nil) != nil {
//
//            }
        }
        
        // Update only if mutableProperties was allocated
        if let newProps = controlCharProps {

            layoutManager.setGlyphs(glyphs, properties: newProps, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
           
            return glyphRange.length

        } else { return 0 }
    }
    
}
