//
//  EditorView.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 12/04/22.
//
import UIKit
import Combine

public class UIEditorView: UIView {
    var isReadOnly = false
    var fileName: String = ""
    
    var text: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    var theme: ThemeVS = ThemeState.shared.theme
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
    private(set) lazy var layoutManager = LayoutManager()
    public private(set) lazy var textContainer = NSTextContainer()
    public private(set) var textView: UITextView!
   
    convenience init(theme: ThemeVS) {
        self.init(frame: CGRect.zero)
        self.theme = theme
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextViewStack()
        observeThemeChanges()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextViewStack()
        observeThemeChanges()
    }
    
    // theme notifcation
    var cancellables: Set<AnyCancellable> = []
    
    private var notificationQueue = DispatchQueue(label: "notification.queue", qos: .userInitiated)
    
    func observeThemeChanges() {
        NotificationCenter.default
            .publisher(for: .themeUpdated)
            .sink { [weak self] notification in
                // Unwrap the sent object
                guard let newTheme = notification.object as? ThemeVS else { return }
                self?.updateTheme(theme: newTheme)
            }
            .store(in: &cancellables)
    }
    
}


extension UIEditorView {
    /**
     Creates and configures the NSTextView, NSTextContainer, NSTextStorage and NSLayoutManager objects
     // TextView -> TextContainer -> LayoutManager -> TextStorage
     */
    func setupTextViewStack() {
        
        // layoutManager <-> textStorage
        self.layoutManager.textStorage = textStorage
        // layoutManager <-> textContainer
        self.layoutManager.addTextContainer(self.textContainer)
        let rect = self.bounds
//        print("bounds: ", self.bounds)
//        let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: width, height: 10000))
//        print("rect: ", rect)
        // textView <-> textContainer
        textView = UITextView(frame: rect, textContainer: textContainer)
//        textView.delegate = self
//        textView.isEditable = false
//        textView.showsVerticalScrollIndicator = false
//        textView.isScrollEnabled = false
        
//        textView.allowsEditingTextAttributes = true
        
        // add textView to scrollView
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
//        self.backgroundColor = UIColor.green
        
        
        
//        textView.contentSize
        
        NSLayoutConstraint.activate([
//            textView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0, constant: -20),
//            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: -20),
//            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            textView.widthAnchor.constraint(equalTo: self.widthAnchor),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
//        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // configureTextContainer
//        textContainer.lineFragmentPadding = 20  // margin padding
//        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.textContainer.widthTracksTextView = true
//        textView.autoresizingMask = [.width]
        self.textView.isFindInteractionEnabled = true
        // set delegate
        self.layoutManager.textStorage?.delegate = self
    }
    
    func setAsEditor(isEditable: Bool) {
        isReadOnly = false
        layoutManager.isReadOnly = false
        
#if targetEnvironment(macCatalyst)
        textContainer.lineFragmentPadding = 20  // margin padding
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            textContainer.lineFragmentPadding = 15  // margin padding
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        } else {
            textContainer.lineFragmentPadding = 10  // margin padding
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
#endif
        textView.isEditable = isEditable
        textView.showsVerticalScrollIndicator = true
        textView.isScrollEnabled = true
        textView.sizeToFit()
        // bottom scroll padding for convenience
        textView.contentInset.bottom = 440
        
        self.textView.backgroundColor = theme.canvasColor.uiColor
    }
    
    func setAsReadOnly() {
        isReadOnly = true
        layoutManager.isReadOnly = true
#if targetEnvironment(macCatalyst)
        textContainer.lineFragmentPadding = 10  // margin padding
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            textContainer.lineFragmentPadding = 8  // margin padding
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        } else {
            textContainer.lineFragmentPadding = 5  // margin padding
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
#endif
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        
        self.textView.backgroundColor = nil // applied in timeline
    }
    
    func refreshLayout() {
        self.layoutManager.invalidateDisplay(forCharacterRange: NSRange())
    }
    
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


