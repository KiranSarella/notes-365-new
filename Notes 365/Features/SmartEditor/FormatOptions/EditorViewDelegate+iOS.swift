//
//  EditorViewDelegate.swift
//  TextKit-Scratch-SwiftUI
//
//  Created by Kiran Sarella on 16/04/22.
//

import UIKit


extension NSAttributedString.Key {
    static let markdown = NSAttributedString.Key(rawValue: "markdown")
    static let markdownRange = NSAttributedString.Key(rawValue: "markdown-range")
    static let markdownInfo = NSAttributedString.Key(rawValue: "markdown-info")
    
    static let defaultAttrubures = NSAttributedString.Key(rawValue: "default-attributes")
}

protocol EditorViewDelegate {

//    func markBold()
}


extension UIEditorView: EditorViewDelegate {
    
//    func printAction() {
//     
//        let printInfo = UIPrintInfo(dictionary: nil)
//        printInfo.jobName = "sample"
//        printInfo.outputType = .general
//        
//        let printController = UIPrintInteractionController.sharedPrintController()!
//        printController.printInfo = printInfo
//        printController.showsNumberOfCopies = false
//        
//        printController.printingItem = imageURL
//        
//        printController.presentAnimated(true, completionHandler: nil)
//        
//    }
    
    // https://www.hackingwithswift.com/example-code/uikit/how-to-render-an-nsattributedstring-to-a-pdf
    func generatePDFData() -> Data? {
        print(#function)
        var pdfTheme = BusinessFactory.themeInteractor().getLightTheme()
        pdfTheme.fontSize = pdfTheme.fontSize * 0.6
        let attrStrGen = MarkdownAttriburedString(theme: pdfTheme.markdownTheme)
        let attrStr = attrStrGen.getAttriburedString(forMarkdown: self.text)
        
        let printFormatter = UISimpleTextPrintFormatter(attributedText: attrStr)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)
        // Use this to get US Letter size instead
        // let pageSize = CGSize(width: 612, height: 792)
        let padding: CGFloat = 40 // 72
        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        // and here's the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    func findAction() {
        textView.findInteraction?.presentFindNavigator(showingReplace: false)
    }
    
    func findAction(with searchText: String) {
        textView.findInteraction?.presentFindNavigator(showingReplace: false)
        textView.findInteraction?.searchText = searchText
        textView.find(nil)
    }
    
    func markBold() {
        guard let selectedTextRange = textView.selectedTextRange else { return }
        let selectedRange = textView.selectedRange
        
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            let newStr = "**\(substr)**"
            // add spaces if not exists
            self.textView.replace(selectedTextRange, withText: newStr)
//            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 4)
        } else {
            // append
            let newStr = "****"
            // add spaces if not exists
            self.textView.replace(selectedTextRange, withText: newStr)
//            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 2, length: selectedRange.length)
        }
        
        textView.delegate?.textViewDidChange?(textView)
    }
    
    func markHighlight() {
        guard let selectedTextRange = textView.selectedTextRange else { return }
//        textView.undoManager?.beginUndoGrouping()
        
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            let newStr = "==\(substr)=="
            self.textView.replace(selectedTextRange, withText: newStr)
            // add spaces if not exists
//            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 4)
        } else {
            // append
            let newStr = "===="
            self.textView.replace(selectedTextRange, withText: newStr)
            // add spaces if not exists
//            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 2, length: selectedRange.length)
        }
        
//        textView.undoManager?.endUndoGrouping()
        
        textView.delegate?.textViewDidChange?(textView)
    }
    
    
    func markItalic() {
        
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0  {
            // append
            let newStr = "*\(substr)*"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 2)
        } else {
            // append
            let newStr = "**"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 1, length: selectedRange.length)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    func headingFontChanged(fontName: String) {
        
//        self.headingFontFamily = fontName
        
        // have to refresh entire editor
        // ?
        
        
        
    }
    
    func markStrikethrough() {
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            let newStr = "~~\(substr)~~"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 4)
        } else {
            // append
            let newStr = "~~~~"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 2, length: selectedRange.length)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    func markInline() {
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            let newStr = "`\(substr)`"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 2)
        } else {
            // append
            let newStr = "``"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 1, length: selectedRange.length)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    func markCodeblock() {
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            let firstLine = if substr.first!.isNewline { "" } else { "\n" }
            let lastLine = if substr.last!.isNewline { "" } else { "\n" }
            // append
            let newStr = "\(firstLine)```\(firstLine)\(substr)\(lastLine)```\(lastLine)"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 8)
        } else {
            // append
            let newStr = "```\n\n```"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 4, length: selectedRange.length)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    func markBlockQuote() {
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            let newStr = "> \(substr)"
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 1)
        } else {
            // append
            let newStr = "> "
            // add spaces if not exists
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
            textView.selectedRange = NSRange(location: selectedRange.location + 1, length: selectedRange.length)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    
    func updateTheme(theme: MarkdownTheme) {
        logger.debug("\(#function)")
        self.theme = theme
        
        // TODO: fix textview.text to textView.text
        // refresh view
        self.textView.text = self.textView.text
        
        // refresh font again
        self.textView.font = theme.font
        self.textView.textColor = theme.bodyColor.uiColor
        
        if isReadOnly == false {
            self.textView.backgroundColor = theme.dynamicCanvasColor.uiColor
        }
    }
    
    func insertImage() {
        
//        let selectedRange = textView.textStorage?.editedRange
//        
//        if selectedRange.length == 0 {
//            return
//        }
        
//        let img = Bundle.main.image(forResource: "one.png")
//        
//        let attachment = NSTextAttachment()
//        attachment.image = img
//        attachment.bounds = CGRect(x: 0, y: 0, width: 860, height: 540)
//        let imageString = NSAttributedString(attachment: attachment)
//        
//        textView.textStorage.append(imageString)
        
        
//        textView.textStorage?.insert(imageString, at: selectedRange.location)
    }
    
    func clearFormat() {
        
        // remove special chars
        // * # ~ `
        let selectedRange = textView.selectedRange
        
        if selectedRange.length == 0 {
            return
        }
        
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange) {
            // append
            
            let cleanStr = substr.replacingOccurrences(of: "[*#~`=]", with: "", options: .regularExpression, range: nil)
            
            self.textView.textStorage.replaceCharacters(in: selectedRange, with: cleanStr)
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    
    func heading(textStyle: TextStyleKey) {
        let selectedRange = textView.selectedRange
        // get string from the selected Range
        let str = textView.text as NSString?   // So we cast String? to NSString?
        if let substr = str?.substring(with: selectedRange), substr.count > 0 {
            // append
            var newStr: String!
            if textStyle == .h1 {
                newStr = "# \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 2)
            } else if textStyle == .h2 {
                newStr = "## \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 3)
            } else if textStyle == .h3 {
                newStr = "### \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 4)
            } else if textStyle == .h4 {
                newStr = "#### \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 5)
            } else if textStyle == .h5 {
                newStr = "##### \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 6)
            } else if textStyle == .h6 {
                newStr = "###### \(substr)"
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length + 7)
            }
        } else {
            // append
            var newStr: String!
            if textStyle == .h1 {
                newStr = "# "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 2, length: selectedRange.length)
            } else if textStyle == .h2 {
                newStr = "## "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 3, length: selectedRange.length)
            } else if textStyle == .h3 {
                newStr = "### "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 4, length: selectedRange.length)
            } else if textStyle == .h4 {
                newStr = "#### "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 5, length: selectedRange.length)
            } else if textStyle == .h5 {
                newStr = "##### "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 6, length: selectedRange.length)
            } else if textStyle == .h6 {
                newStr = "###### "
                self.textView.textStorage.replaceCharacters(in: selectedRange, with: newStr)
                textView.selectedRange = NSRange(location: selectedRange.location + 7, length: selectedRange.length)
            }
        }
        textView.delegate?.textViewDidChange?(textView)
    }
    
    
    func performUndo() {
        textView.undoManager?.undo()
    }
    
    func performRedo() {
        textView.undoManager?.redo()
    }
}


