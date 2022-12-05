//
//  EditorView.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//

#if os(macOS)

import AppKit

public class EditorView: NSView {
    
    var theme: MarkdownTheme = ThemeBusiness.generateBlackWhiteTheme()
    
    
    
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
    private lazy var smartLayoutManagerDelegate = SmartLayoutManagerDelegate(textView: textView)
    private lazy var markdownlayoutManagerDelegate = MarkdownLayoutManagerDelegate(textView: textView)
    
    public private(set) lazy var textContainer = NSTextContainer()
    public private(set) var textView: NSTextView!
    public private(set) lazy var scrollview = NSScrollView()
    
    
    
    func setupTextViewStack() {
        
        // create textView with container
        textView = EditorTextView(frame: self.bounds, textContainer: textContainer)
        textView.delegate = self
        
        // add textView to scrollView
        scrollview.documentView = textView
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        // add scroll view to Base View
        addSubview(scrollview)
        NSLayoutConstraint.activate([
            scrollview.widthAnchor.constraint(equalTo: self.widthAnchor),
            scrollview.topAnchor.constraint(equalTo: self.topAnchor),
            scrollview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
    }
    
    convenience init(theme: MarkdownTheme) {
        
        self.init(frame: NSRect.zero)
        self.theme = theme
    }
    
    public override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
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
        self.textView.textContainerInset = NSSize(width: 40, height: 40)
        
        self.layoutManager.addTextContainer(self.textContainer)
        
        let contentSize = self.scrollview.contentSize
        self.textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        self.textContainer.widthTracksTextView = true
    }
    
    internal func configureTextView() {
        // TextView -> TextContainer -> LayoutManager -> TextStorage
        
        configureTextContainer()
        
        let contentSize = self.scrollview.contentSize
        
        self.textView.minSize = CGSize(width: 0, height: 0)
        self.textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        self.textView.isVerticallyResizable = true
        self.textView.isHorizontallyResizable = false
        self.textView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        
        textView.autoresizingMask = [.width]
        
        self.textView.allowsUndo = true
//        self.textView.usesFindPanel = true
        self.textView.usesFindBar = true
        self.textView.showFindIndicator(for: NSRange(location: 20, length: 200))
//        self.textView.usesRuler = true
        
//        self.textView.backgroundColor = NSColor.magenta
        

        
        self.scrollview.borderType = .noBorder
        self.scrollview.hasVerticalScroller = true
        self.scrollview.hasHorizontalScroller = false
        self.scrollview.documentView = self.textView
        
        self.scrollview.wantsLayer = true
    }
 
    
    func refreshLayout() {
        
//        textContainer.replaceLayoutManager(layoutManager)
        
        self.layoutManager.invalidateDisplay(forCharacterRange: NSRange())
    }
    
    // storage
    func setupNewEditor() {
        
        self.layoutManager.replaceTextStorage(textStorage)  // this is imp. routne assign will not work
        self.layoutManager.textStorage?.delegate = self
        self.layoutManager.delegate =  smartLayoutManagerDelegate
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
        
        // scroll to cursor rect
        if let cursorRange = textView.selectedRanges.first?.rangeValue {
            textView.scrollRangeToVisible(cursorRange)
        }
    }
    
    func switchToMarkdownEditorMode() {
        
        layoutManager.delegate = nil
        textContainer.replaceLayoutManager(layoutManager)
        
        // scroll to cursor rect
        if let cursorRange = textView.selectedRanges.first?.rangeValue {
            textView.scrollRangeToVisible(cursorRange)
        }
    }
}


// auto formatting
extension EditorView {
    
    
    
}


// text view delegate

extension EditorView: NSTextViewDelegate {
    
    public func textViewDidChangeSelection(_ notification: Notification) {
//        print(#function)
//        print(textView.selectedRange())
        
    }
}

extension EditorView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
     
//        if editedMask.contains(.editedAttributes) {
////            print("editedAttributes")
//        }
//        if editedMask.contains(.editedCharacters) == false {
////            print("editedCharacters")
//            return
//        }
        
//        // get editedCharacter
//        if delta == 1 {
//            let charRange = (textStorage.string as NSString).rangeOfComposedCharacterSequence(at: editedRange.location)
////            print(charRange)
//            let editedChar = (textStorage.string as NSString).substring(with: charRange)
////            print(editedChar)
//
////            if editedChar == "*" {
////
////            }
//
//            if let fontAttr = textStorage.attribute(.font, at: editedRange.location, effectiveRange: nil) {
//                print(fontAttr)
//            }
//
//        }
        
//        print("editedRange", editedRange, "delta", delta, "editedMask", editedMask)
        
        let extendedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
//        print("extendedRange", extendedRange)
        
        // remove bold, italic traits
        textStorage.enumerateAttribute(.font, in: extendedRange, options: []) { value, range, stop in
            guard let font = value as? NSFont else { return }
            
            var symbolicTraits = font.fontDescriptor.symbolicTraits
            symbolicTraits.remove([.bold, .italic])
            
            let fontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits)
//            print(fontDescriptor, range)
            let newFont = NSFont(descriptor: fontDescriptor, size: CGFloat(theme.font.pointSize))!
            textStorage.addAttribute(.font, value: newFont, range: range)
            
//            let attrSubStr = textStorage.attributedSubstring(from: range)
//            print(attrSubStr.string)
            
//            if let language = NSLinguisticTagger.dominantLanguage(for: attrSubStr.string) {
//                print("language", attrSubStr.string, language)
//                if language == "en" {
//                    let bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
//                    textStorage.addAttribute(.font, value: bodyFont, range: range)
//                }
//            } else {
//                print("language", attrSubStr.string, "Unknown language")
////                let bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
////                textStorage.addAttribute(.font, value: bodyFont, range: range)
//            }
            
//            let bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
//            textStorage.addAttribute(.font, value: bodyFont, range: range)
            
//            print("classDescription", fontDescriptor.classDescription)
//            fontDescriptor.classDescription

//            print("matchingFontDescriptor", fontDescriptor.matchingFontDescriptor(withMandatoryKeys: [.family]))

//            if font.fontName.contains(theme.bodyFontName) ||
//                font.fontName.contains(theme.codeFontName) ||
//                font.fontName.contains(theme.blockQuoteFontName) ||
//                font.fontName.contains(theme.headingFontName)
//            {
//                let bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
////                fontDescriptor = bodyFont.fontDescriptor.withSymbolicTraits(symbolicTraits)
////                fontDescriptor = fontDescriptor.withFamily(bodyFont.familyName!)
//
//                textStorage.addAttribute(.font, value: bodyFont, range: range)
//            }



//            fontDescriptor = fontDescriptor.withFamily(bodyFont.familyName!)
//            print(bodyFont.familyName!)

//            fontDescriptor = fontDescriptor.withFamily(bodyFont?.familyName ?? NSFont.systemFont(ofSize: 14).familyName!)
//            fontDescriptor = fontDescriptor.withFamily(NSFont.systemFont(ofSize: 14).familyName!)

//            let newFont = NSFont(descriptor: fontDescriptor, size: CGFloat(theme.bodyFontSize))!
//
////            let newFont = font.apply(newTraits: symbolicTraits, newPointSize: theme.bodyFontSize)
//            textStorage.addAttribute(.font, value: newFont, range: range)

//            print("after:", newFont.fontDescriptor.symbolicTraits, range)
//            print(newFont.fontDescriptor)
//
//            let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 1))
//            innerAttributedString.addAttribute(.font, value: newFont, range: range)
//            textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
        }
        
//        textStorage.removeAttribute(.font, range: extendedRange)
        textStorage.removeAttribute(.markdown, range: extendedRange)
        textStorage.removeAttribute(.markdownRange, range: extendedRange)
        textStorage.removeAttribute(.foregroundColor, range: extendedRange)
//        textStorage.removeAttribute(.paragraphStyle, range: extendedRange)
        textStorage.removeAttribute(.underlineColor, range: extendedRange)
        textStorage.removeAttribute(.underlineStyle, range: extendedRange)
        
//        textStorage.enumerateAttributes(in: extendedRange) { attribureKeys, range, pointer in
//            print(attribureKeys, range)
//        }

        
        textStorage.addAttribute(.markdownRange, value: MarkdownPattern.body, range: extendedRange)
        
//        var bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
//        print("before:", bodyFont.fontDescriptor.symbolicTraits, extendedRange)
////        let fontDescirptor = bodyFont.fontDescriptor.withSymbolicTraits(.classSansSerif)
////        print("after-desc:", fontDescirptor.symbolicTraits, extendedRange)
////        bodyFont = NSFont(descriptor: fontDescirptor, size: CGFloat(theme.bodyFontSize))!
//        textStorage.addAttribute(.font, value: bodyFont, range: extendedRange)
//
//        print("after:", bodyFont.fontDescriptor.symbolicTraits, extendedRange)
//
        textStorage.addAttribute(.foregroundColor, value: NSColor(theme.bodyColor.color), range: extendedRange)

        
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
        processCodeBlock(extendedRange: extendedRange, textStorage: textStorage)
        
        
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
//                    guard let font = value as? NSFont else { return }
//
//                    if font.fontName.contains(theme.bodyFontName) ||
//                        font.fontName.contains(theme.codeFontName) ||
//                        font.fontName.contains(theme.blockQuoteFontName) ||
//                        font.fontName.contains(theme.headingFontName)
//                    {
//                        let bodyFont = NSFont(name: theme.bodyFontName, size: CGFloat(theme.bodyFontSize))!
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
//            //            fontDescriptor = fontDescriptor.withFamily(bodyFont?.familyName ?? NSFont.systemFont(ofSize: 14).familyName!)
//            //            fontDescriptor = fontDescriptor.withFamily(NSFont.systemFont(ofSize: 14).familyName!)
//
//            //            let newFont = NSFont(descriptor: fontDescriptor, size: CGFloat(theme.bodyFontSize))!
//            //
//            ////            let newFont = font.apply(newTraits: symbolicTraits, newPointSize: theme.bodyFontSize)
//            //            textStorage.addAttribute(.font, value: newFont, range: range)
//
//            //            print("after:", newFont.fontDescriptor.symbolicTraits, range)
//            //            print(newFont.fontDescriptor)
//            //
//            //            let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 1))
//            //            innerAttributedString.addAttribute(.font, value: newFont, range: range)
//            //            textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
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
                guard let font = value as? NSFont else { return }
                // bold
                let newFont = font.apply(newTraits: .bold)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
//                // foreground color
//                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h1Color.color), range: range)
            }
            
            
//            innerAttributedString.addAttribute(.font,
//                                               value: boldFont,
//                                               range: styleRange)
            
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: NSColor(theme.styleColor.color), range: styleRange)
            
            // markdown
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)
            
            // add id key
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
                guard let font = value as? NSFont else { return }
                // bold
                let newFont = font.apply(newTraits: .italic)
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h1Color.color), range: range)
            }
            
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: NSColor(theme.styleColor.color), range: styleRange)
            
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
                guard let font = value as? NSFont else { return }
                // bold
                let newFont = font.apply(newTraits: [.bold, .italic])
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                //                // foreground color
                //                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h1Color.color), range: range)
            }
            
            // color
            innerAttributedString.addAttribute(.foregroundColor,
                                               value: NSColor(theme.styleColor.color), range: styleRange)
            
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
                                               value:  NSColor(theme.styleColor.color),
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // strikethrough line
            innerAttributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                    value:  NSUnderlineStyle.single.rawValue,
                                                    range: NSRange(location: match!.range.location + 2, length: match!.range.length - 4))
            // line color
            innerAttributedString.addAttribute(.strikethroughColor,
                                               value:  NSColor(theme.styleColor.color),
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
    
    
    func processLink(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.link.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
//            innerAttributedString.addAttribute(.foregroundColor,
//                                               value:  NSColor(theme.linkColor.color),
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineStyle,
//                                                    value:  NSUnderlineStyle.single.rawValue,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//            innerAttributedString.addAttribute(.underlineColor,
//                                                    value:  NSColor(theme.linkColor.color),
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.link, value: NSURL(string: "http://notes365.app")!, range: match!.range)
            
            innerAttributedString.addAttribute(.strokeColor,
                                               value:  NSColor.red,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            innerAttributedString.addAttribute(.foregroundColor,
                                               value:  NSColor.red,
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineStyle,
                                                                value:  NSUnderlineStyle.single.rawValue,
                                                                range: NSRange(location: match!.range.location, length: match!.range.length))
                        innerAttributedString.addAttribute(.underlineColor,
                                                           value:  NSColor.red,
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
            
            // font
            innerAttributedString.addAttribute(.font,
                                               value:  theme.font.withSize(theme.font.pointSize - 2),
                                               range: NSRange(location: match!.range.location, length: match!.range.length))
            
            // foreground
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  NSColor(theme.codeColor.color),
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            
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
    
    
    func processOrderedList(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        let pattern = MarkdownPattern.orderedList.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            
            innerAttributedString.addAttribute(.font,
                                               value:  theme.font,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                               value:  NSColor(theme.listColor.color),
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
                                               value: NSColor(theme.listColor.color),
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
                                               value: NSColor(theme.listColor.color),
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
    
    
    func processCodeBlock(extendedRange: NSRange, textStorage innerAttributedString: NSTextStorage) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.minimumLineHeight = 10
        paragraphStyle.lineSpacing = 10
        
        let globalBlock = NSTextBlock()
        globalBlock.setWidth(140, type: .absoluteValueType, for: .padding, edge: .minX)
        globalBlock.setContentWidth(100, type: .percentageValueType)
        
        let paddingTextCodeBlock = NSTextBlock()
        paddingTextCodeBlock.setContentWidth(80, type: .percentageValueType)
        //        paddingTextCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        paddingTextCodeBlock.setBorderColor(.gray)
        paddingTextCodeBlock.setWidth(1, type: .absoluteValueType, for: .border)
        //        paddingTextCodeBlock.setWidth(20, type: .absoluteValueType, for: .padding, edge: .minX)
        paddingTextCodeBlock.backgroundColor = NSColor.lightGray
        
        
        let textCodeBlock = NSTextBlock()
        textCodeBlock.setWidth(30, type: .absoluteValueType, for: .padding)
        textCodeBlock.backgroundColor = NSColor.lightGray
        //        textCodeBlock.setWidth(20, type: .absoluteValueType, for: .margin)
        textCodeBlock.setContentWidth(60, type: .percentageValueType)
        
        
        //        let codeBlock = TweetTextBlock()
        
        paragraphStyle.textBlocks = [globalBlock, paddingTextCodeBlock]
        
        //        paragraphStyle.textBlocks = [codeBlock]
        
        let pattern = MarkdownPattern.codeBlock.rawValue
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        
        regex.enumerateMatches(in: innerAttributedString.string, options: [], range: extendedRange) {
            match, flags, stop in
            
            let range = NSRange(location: match!.range.location, length: match!.range.length)
            
            innerAttributedString.enumerateAttribute(.font, in: range, options: []) { value, range, stop in
                guard let font = value as? NSFont else { return }
                // bold
                let newFont = font.apply(newTraits: .monoSpace, newPointSize: CGFloat(theme.font.pointSize - 2))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.codeColor.color), range: range)
            }
            
//            var font = NSFont(name: theme.codeFontName, size: CGFloat(theme.bodyFontSize - 2))
////            font = font.apply(newTraits: .expanded)
//
//            innerAttributedString.addAttribute(.font,
//                                                    value:  font,
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
//
//            innerAttributedString.addAttribute(.foregroundColor,
//                                               value:  NSColor(theme.codeBlockColor),
//                                                    range: NSRange(location: match!.range.location, length: match!.range.length))

            let regExCharLenght = 3
            let backPadding = 0
            // markdown
            let startRange = NSRange(location: match!.range.location, length: regExCharLenght)
            let endRange = NSRange(location: match!.range.location + match!.range.length - regExCharLenght - backPadding , length: regExCharLenght)
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: startRange)
            
            // add id key
            innerAttributedString.addAttribute(NSAttributedString.Key.markdown,
                                               value: 0,
                                               range: endRange)
            
            
            
            let info: [String: Any] = [
                "range": NSRange(location: match!.range.location, length: match!.range.length),
                "type": "codeblock"
            ]
            // info
            innerAttributedString.addAttribute(NSAttributedString.Key.markdownInfo,
                                                    value: info,
                                                    range: NSRange(location: match!.range.location, length: match!.range.length))
            
            innerAttributedString.addAttribute(.markdownRange, value: MarkdownPattern.codeBlock, range: match!.range)
        }
    }
    
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
                                               value:  NSColor(theme.blockQuoteColor.color),
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
                guard let font = value as? NSFont else { return }
                // bold
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 1))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                // foreground color
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h1Color.color), range: range)
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
                guard let font = value as? NSFont else { return }
                
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 2))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h2Color.color), range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 2)),
//                                                    range: NSRange(location: match!.range.location + 3, length: match!.range.length - 3))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: NSColor.systemCyan,
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
                guard let font = value as? NSFont else { return }
                
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 3))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h3Color.color), range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 3)),
//                                                    range: NSRange(location: match!.range.location + 4, length: match!.range.length - 4))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: NSColor.systemTeal,
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
                guard let font = value as? NSFont else { return }
                
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 4))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h4Color.color), range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 4)),
//                                                    range: NSRange(location: match!.range.location + 5, length: match!.range.length - 5))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: NSColor.systemBrown,
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
                guard let font = value as? NSFont else { return }
                
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 5))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h5Color.color), range: range)
            }
            
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 5)),
//                                                    range: NSRange(location: match!.range.location + 6, length: match!.range.length - 6))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: NSColor.systemIndigo,
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
                guard let font = value as? NSFont else { return }
                
                let newFont = font.apply(newTraits: .bold, newPointSize: getHeadingFontSize(level: 6))
                innerAttributedString.addAttribute(.font, value: newFont, range: range)
                innerAttributedString.addAttribute(.foregroundColor, value: NSColor(theme.h6Color.color), range: range)
            }
            
//            innerAttributedString.addAttribute(NSAttributedString.Key.font,
//                                                    value: NSFont.boldSystemFont(ofSize: getHeadingFontSize(level: 6)),
//                                                    range: NSRange(location: match!.range.location + 7, length: match!.range.length - 7))
//
//            innerAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                                    value: NSColor.systemMint,
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
    
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: NSFont, forGlyphRange glyphRange: NSRange) -> Int {
        
//        print(#function)
        
        
//
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


#endif
