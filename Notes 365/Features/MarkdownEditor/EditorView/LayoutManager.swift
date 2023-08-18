// Copyright (c) 2018-2021  Brian Dewey. Covered by the Apache 2.0 license.

import Foundation
import UIKit

//private let logger = Logger(label: "org.brians-brian.CommonplaceBookApp.LayoutManager")

/// Custom layout manager that knows how to draw vertical bars next to block quotes.
/// Implementation inspired by the Wordpress Aztec HTML editing component:
/// https://github.com/wordpress-mobile/AztecEditor-iOS/blob/develop/Aztec/Classes/TextKit/LayoutManager.swift
final class LayoutManager: NSLayoutManager {
  override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    drawBlockquotes(forGlyphRange: glyphsToShow, at: origin)
  }
}

// MARK: - Private

private extension LayoutManager {
  /// Text with a `.blockquoteBorderColor` attribute gets rendered as a block quote:
  /// - The background is `quaternarySystemFill`
  /// - A 4 point border on the left edge is filled with `blockquoteBorderColor`
  func drawBlockquotes(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    guard let textStorage else {
      return
    }

    guard let context = UIGraphicsGetCurrentContext() else {
      preconditionFailure("When drawBackgroundForGlyphRange is called, the graphics context is supposed to be set by UIKit")
    }

    print(glyphsToShow)
    let characterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
      print(characterRange)
    textStorage.enumerateAttribute(.blockquoteBorderColor, in: characterRange, options: []) { object, range, _ in
        
//        print(object, range)
        
      guard let color = object as? UIColor else {
        return
      }
        
        
    
                let nRange = NSIntersectionRange(glyphsToShow, range)
                if nRange.length == 0 {
                    return
                }
                if let tc = self.textContainer(forGlyphAt:nRange.location, effectiveRange:nil, withoutAdditionalLayout:true) {
                    var r = self.boundingRect(forGlyphRange:nRange, in:tc)
                    r.origin.x += origin.x
                    r.origin.y += origin.y
                    
//                    let c = UIGraphicsGetCurrentContext()!
//                    c.saveGState()
//                    c.setStrokeColor(UIColor.black.cgColor)
//                    c.setLineWidth(1.0)
//                    c.stroke(r)
//                    c.restoreGState()
                    
                    guard let context = UIGraphicsGetCurrentContext() else { return }

                     context.saveGState()
                     defer { context.restoreGState() }

                    let path = UIBezierPath(roundedRect: r, cornerRadius: 8.0)

                     context.addPath(path.cgPath)
                     context.closePath()

//                    UIColor.quaternarySystemFill.setFill()
//                    path.fill()
                    
                    // rgb(245, 245, 245)
                    let fillColor = UIColor(white: 0.9, alpha: 0.2)
//                    let lineColor = UIColor(white: 0.9, alpha: 0.1)
                    
                    context.setLineWidth(1.0)
                    context.setStrokeColor(UIColor.secondarySystemFill.cgColor)
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
}


public extension NSAttributedString.Key {
  /// A UIColor to use when rendering a vertical bar on the leading edge of a block quote.
  static let blockquoteBorderColor = NSAttributedString.Key(rawValue: "verticalBarColor")
}
