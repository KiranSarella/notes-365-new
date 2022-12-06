//
//  ThemePreview.swift
//  Notes 365
//
//  Created by Kiran Sarella on 02/07/22.
//

#if os(macOS)

import SwiftUI
import AppKit


struct ThemePreviewView: View {
    
    var theme: MarkdownTheme
    
    @State private var attrStr = AttributedString()
    @State private var zoomLevel = 0.8
    @State private var focusedOnPreview = false
    let previewContent = ThemePreviewView.loadContent()
    
    static func loadContent() -> String {
        let path = Bundle.main.path(forResource: "PreviewContent", ofType: "md")!
        return try! String(contentsOfFile: path, encoding: .utf8)
    }
    
    func getAttrStr(_ zoomLevel: CGFloat) -> AttributedString {
        
        var themeZoomed = theme
        themeZoomed.fontSize = themeZoomed.fontSize * Float(zoomLevel)
        
//        themeZoomed.font = themeZoomed.font.withSize(themeZoomed.font.pointSize * (75 / 100))
//        themeZoomed.font = themeZoomed.font.withSize(themeZoomed.font.pointSize * zoomLevel)
        
        let markdownAttrStr = MarkdownAttriburedString(theme: themeZoomed)
        let newAttS = markdownAttrStr.getAttriburedString(forMarkdown: previewContent)
        return AttributedString(newAttS)
    }
    
    var body: some View {
        
        VStack {
            VStack {
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(getAttrStr(zoomLevel))
                        // .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            .padding()
                            .background(Color(NSColor.textBackgroundColor))
                            .lineSpacing(EditorSettings.lineSpacing)
                    }
                    .cornerRadius(4)
                    .padding([.top, .bottom, .trailing])
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Slider(value: $zoomLevel, in: 0.6...1.0, step: 0.10) {
                                
                            } minimumValueLabel: {
                                Text("60%")
                                    .fontWeight(.ultraLight)
                                    .font(.system(size: 8))
                            } maximumValueLabel: {
                                Text("100%")
                                    .fontWeight(.ultraLight)
                                    .font(.system(size: 8))
                            } onEditingChanged: { _ in
                                
                            }
                            .opacity(focusedOnPreview ? 1 : 0)
                            .padding(EdgeInsets(top: 0, leading: 160, bottom: 20, trailing: 30))
                        }
                    }
                }
                .onHover { status in
                    focusedOnPreview = status
                }
            }
            Text("Preview")
                .font(Font.footnote)
                .foregroundColor(.secondary)
                .padding(EdgeInsets(top: -18, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
}

#endif
