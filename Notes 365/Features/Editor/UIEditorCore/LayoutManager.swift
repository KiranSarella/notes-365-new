// Copyright (c) 2018-2021  Brian Dewey. Covered by the Apache 2.0 license.

import Foundation
import UIKit

/// Custom layout manager that knows how to draw vertical bars next to block quotes.
/// Implementation inspired by the Wordpress Aztec HTML editing component:
/// https://github.com/wordpress-mobile/AztecEditor-iOS/blob/develop/Aztec/Classes/TextKit/LayoutManager.swift
final class LayoutManager: NSLayoutManager {
    
    var isReadOnly: Bool = false
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        print(#function, glyphsToShow, origin)
        //      print(#function)
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        
        drawCodeBlock(forGlyphRange: glyphsToShow, at: origin)
        drawBlockquotes(forGlyphRange: glyphsToShow, at: origin)
    }
}

// MARK: - Private

private extension LayoutManager {
    
    
    func drawCodeBlock(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard let textStorage else {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            preconditionFailure("When drawBackgroundForGlyphRange is called, the graphics context is supposed to be set by UIKit")
        }
        
        //    print(glyphsToShow)
        let characterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        //      print(characterRange)
        textStorage.enumerateAttribute(.codeBlockBackground, in: characterRange, options: []) { object, range, _ in
            
            //        print(object, range)
            guard let color = object as? UIColor else {
              return
            }
            
            let nRange = NSIntersectionRange(glyphsToShow, range)
            if nRange.length == 0 {
                return
            }
            
            if let tc = self.textContainer(forGlyphAt: nRange.location, effectiveRange: nil, withoutAdditionalLayout: true) {
                
                let nRange = NSRange(location: nRange.location, length: nRange.length)
                // prepare rect
                var r = self.boundingRect(forGlyphRange:nRange, in:tc)
                r.origin.x += origin.x
                r.origin.y += origin.y
                
                r = r.offsetBy(dx: origin.x - 10, dy: origin.y + 3)
                
                //                    let c = UIGraphicsGetCurrentContext()!
                //                    c.saveGState()
                //                    c.setStrokeColor(UIColor.black.cgColor)
                //                    c.setLineWidth(1.0)
                //                    c.stroke(r)
                //                    c.restoreGState()
                
                
                context.saveGState()
                defer { context.restoreGState() }
                
                let path = UIBezierPath(roundedRect: r, cornerRadius: 8.0)
                
                context.addPath(path.cgPath)
                context.closePath()
                
                //                    UIColor.quaternarySystemFill.setFill()
                //                    path.fill()
                
                // rgb(245, 245, 245)
                //            let fillColor = UIColor(white: 0.9, alpha: 0.2)
                let fillColor = UIColor.gray.withAlphaComponent(0.03)
                let lineColor = UIColor.gray.withAlphaComponent(0.3)
                
                context.setLineWidth(1.0)
                context.setStrokeColor(lineColor.cgColor)
                context.setFillColor(fillColor.cgColor)
                //                     context.strokePath()
                context.drawPath(using: .fillStroke)
            }
            
            
            //      let verticalBarGlyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            //      enumerateLineFragments(forGlyphRange: verticalBarGlyphRange) { rect, _, _, _, _ in
            
            
            // vertical bar
            //            var verticalBarRect = rect.offsetBy(dx: origin.x, dy: origin.y)
            //            UIColor.quaternarySystemFill.setFill()
            //            context.fill(verticalBarRect)
            //            verticalBarRect.size.width = 4
            //            color.setFill()
            //            context.fill(verticalBarRect)
            
            
            //          // background
            //          UIColor.quaternarySystemFill.setFill()
            //          // vertical bar
            //          var verticalBarRect = rect.offsetBy(dx: origin.x, dy: origin.y)
            //          context.fill(verticalBarRect)
            //          verticalBarRect.size.width = 4
            //          color.setFill()
            //          context.fill(verticalBarRect)
            
            //          var r = rect.offsetBy(dx: origin.x + 20, dy: origin.y - 20)
            //          context.saveGState()
            //          context.setStrokeColor(UIColor.red.cgColor)
            //          context.setLineWidth(2.0)
            //          context.stroke(r)
            //          context.restoreGState()
            //      }
        }
    }
    
    
//    func drawBlockquotes(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        guard let textStorage else { return }
//
//        guard let context = UIGraphicsGetCurrentContext() else {
//            preconditionFailure("When drawBackgroundForGlyphRange is called, the graphics context is supposed to be set by UIKit")
//        }
//
//        let characterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
//        textStorage.enumerateAttribute(.codeBlockBackground, in: characterRange, options: []) { object, range, _ in
//
//            guard let color2 = object as? String, color2 == "blockQuote" else {
//              return
//            }
//
//            let nRange = NSIntersectionRange(glyphsToShow, range)
//            if nRange.length == 0 {
//                return
//            }
//
//            let color = UIColor.orange
//
//            if let tc = self.textContainer(forGlyphAt: nRange.location, effectiveRange: nil, withoutAdditionalLayout: true) {
//
//                let nRange = NSRange(location: nRange.location, length: nRange.length)
//                // prepare rect
//                var r = self.boundingRect(forGlyphRange:nRange, in:tc)
//                r.origin.x += origin.x
//                r.origin.y += origin.y
//
////                r = r.offsetBy(dx: origin.x - 10, dy: origin.y + 3)
//
//                //                    let c = UIGraphicsGetCurrentContext()!
//                //                    c.saveGState()
//                //                    c.setStrokeColor(UIColor.black.cgColor)
//                //                    c.setLineWidth(1.0)
//                //                    c.stroke(r)
//                //                    c.restoreGState()
//
//
//                context.saveGState()
//                defer { context.restoreGState() }
//
//                // vertical bar
//                var verticalBarRect = r.offsetBy(dx: origin.x + 10, dy: origin.y)
////                context.fill(verticalBarRect)
//                verticalBarRect.size.width = 4
//                color.setFill()
//                context.fill(verticalBarRect)
//            }
//
//
//
//        }
//    }
    
    func drawBlockquotes(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard let textStorage else { return }

        guard let context = UIGraphicsGetCurrentContext() else {
            preconditionFailure("When drawBackgroundForGlyphRange is called, the graphics context is supposed to be set by UIKit")
        }

        let characterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        textStorage.enumerateAttribute(.codeBlockBackground, in: characterRange, options: []) { object, range, _ in

            let nRange = NSIntersectionRange(glyphsToShow, range)
            if nRange.length == 0 {
                return
            }
            
            guard let info = object as? [String : Any],
                  let code = info["code"] as? String, code == "blockQuote",
                  let color0 = info["color"] as? UIColor
            else {
              return
            }
//            let color = color0.withAlphaComponent(0.15)
            let color = color0.withAlphaComponent(0.8)
            let verticalBarGlyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            enumerateLineFragments(forGlyphRange: verticalBarGlyphRange) { rect, _, _, _, _ in

                context.saveGState()
                defer { context.restoreGState() }
                
                let gap: CGFloat = self.isReadOnly ? 10 : 20
                
                // vertical bar
                var verticalBarRect = rect.offsetBy(dx: origin.x + gap, dy: origin.y - 4)
//                context.fill(verticalBarRect)
                verticalBarRect.size.width = 4
                color.setFill()
                context.fill(verticalBarRect)

                // background
                var bgRect = rect
                bgRect.size.width = bgRect.width - 40   // maintain trailing padding
                let bgPath = UIBezierPath(rect: bgRect.offsetBy(dx: origin.x + gap, dy: origin.y - 4))
                color0.withAlphaComponent(0.05).setFill()
                bgPath.fill()
                
                
                // highlight demo
//                let path = UIBezierPath()
//                path.lineWidth = 40.0
//                path.lineCapStyle = .round
//                
//                let startX = rect.origin.x
//                let startY = rect.origin.y + rect.size.height / 2.0
//                
//                path.move(to: CGPoint(x: startX, y: startY))
//                
//                for _ in stride(from: startX, to: startX + rect.size.width, by: 1) {
//                    let randomYOffset = CGFloat(arc4random_uniform(UInt32(rect.size.height))) - rect.size.height / 2.0
//                    path.addLine(to: CGPoint(x: startX + path.currentPoint.x - startX + 6, y: startY + randomYOffset))
//                    path.move(to: CGPoint(x: startX + path.currentPoint.x - startX + 3, y: startY + randomYOffset))
//                }
//                
//                UIColor.yellow.setStroke()
//                path.stroke()
                
            }
        }
    }
    
    
//    func highlightText(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        
//        let paragraphRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
//        let text: String = String(textStorage?.string.substring(with: paragraphRange) ?? "")
//        let range = (textStorage?.string as NSString?)?.range(of: text)
//        
//        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byParagraphs) { substring, substringRange, enclosingRange, isConverted in
//            
//            let fullRange = NSRange(location: enclosingRange.location + paragraphRange.location, length: substringRange.length)
//            
//            let attributes = textStorage?.attributes(at: fullRange.location, effectiveRange: nil)
//            
//            let isHighlight = (attributes?[.sketchHighlight] as? Bool) ?? false
//            
//            if isHighlight {
//                let bounds = self.boundingRect(forGlyphRange: NSRange(substringRange, in: text), in: self.textContainers[0])
//                let rect = CGRect(x: bounds.origin.x + origin.x, y: bounds.origin.y + origin.y, width: bounds.width, height: bounds.height)
//                
//                let path = UIBezierPath(roundedRect: rect.insetBy(dx: -5, dy: -2), cornerRadius: 8)
//                UIColor.yellow.setStroke()
//                path.lineWidth = 2
//                path.stroke()
//            }
//        }
//    }
}


public extension NSAttributedString.Key {
    static let codeBlockBackground = NSAttributedString.Key(rawValue: "notes365.codeBlockBackground")
    static let blockQuoteBackground = NSAttributedString.Key(rawValue: "notes365.codeBlockBackground")
}
