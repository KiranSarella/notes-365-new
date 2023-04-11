//
//  FontPicker.swift
//  Notes 365
//
//  Created by Kiran Sarella on 05/02/23.
//

import SwiftUI

/// A SwiftUI View based on the UIFontPickerViewController in UIKit
public struct FontPicker {
    
    var configuration: UIFontPickerViewController.Configuration
    var didPickFont: (UIFont) -> ()
    var onCancel: (() -> Void)?
    
    /// Initializes the Font Picker View
    /// - Parameter configuration: A configuration object - see UIFontPickerViewController.Configuration for details
    /// - Parameter didPickFont: A completion handler determining what to do with the selected font.
    public init(configuration: UIFontPickerViewController.Configuration = .init(), didPickFont: @escaping (UIFont) -> ()) {
        self.configuration = configuration
        self.didPickFont = didPickFont
    }
    
    /* internal - do not use this from outside */
    init(configuration: UIFontPickerViewController.Configuration = .init(), didPickFont: @escaping (UIFont) -> (), onCancel: (() -> ())?) {
        self.configuration = configuration
        self.didPickFont = didPickFont
        self.onCancel = onCancel
    }
}

// MARK: - UIViewControllerRepresentable
extension FontPicker: UIViewControllerRepresentable {
    public func makeCoordinator() -> FontPicker.Coordinator {
        Coordinator(onCancel: onCancel, didPickFont: didPickFont)
    }
    
    public func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let controller = UIFontPickerViewController(configuration: configuration)
        
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ viewController: UIFontPickerViewController, context: Context) {
        
    }
}

// MARK: - Modifiers
extension FontPicker {
    
    /// Enables the caller to know when a user has canceled their interaction with the font selection screen.
    /// - Parameter handler: The function that is called if a user cancels the font selection screen
    public func onCancel(_ handler: @escaping () -> ()) -> Self {
        FontPicker(configuration: configuration, didPickFont: didPickFont, onCancel: handler)
    }
}

// MARK: - Coordinator
extension FontPicker {
    public class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        var onCancel: (() -> Void)?
        var didPickFont: (UIFont) -> ()
        
        init(onCancel: (() -> Void)?, didPickFont: @escaping (UIFont) -> ()) {
            self.onCancel = onCancel
            self.didPickFont = didPickFont
        }
        
        public func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            self.onCancel?()
        }
        
        public func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            
            guard let fontDescriptor = viewController.selectedFontDescriptor else { return }
            let uifont = UIFont(descriptor: fontDescriptor, size: 28.0)
            self.didPickFont(uifont)
        }
    }
}


