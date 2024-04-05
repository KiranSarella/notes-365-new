//
//  TableOfContentsView.swift
//  Notes 365
//
//  Created by kiran ipc on 05/04/24.
//

import SwiftUI


extension MarkdownHeading {
    
    // index related
    func next() -> MarkdownHeading {
        switch self {
        case .h1:
            return MarkdownHeading.h2
        case .h2:
            return MarkdownHeading.h3
        case .h3:
            return MarkdownHeading.h4
        case .h4:
            return MarkdownHeading.h4
        }
    }
    
    var indexColor: Color {
        
        Color.primary
        
//        switch self {
//        case .h1:
//            return Color.primary
//        case .h2:
//            return Color(hex: 0x941100)
//        case .h3:
//            return Color(hex: 0x929000)
//        case .h4:
//            return Color(hex: 0x009051)
//        }
    }
    
    var indexWeight: Font.Weight {
        
        switch self {
        case .h1:
            return .bold
        case .h2:
            return .semibold
        case .h3:
            return .medium
        case .h4:
            return .regular
        }
    }
    
    var indexFontSize: CGFloat {
        return 18
//        switch self {
//        case .h1:
//            return 28
//        case .h2:
//            return 24
//        case .h3:
//            return 20
//        case .h4:
//            return 18
//        }
    }

}


struct TableOfContentsView: View {
    @Binding var items: [ContentItem]
    @Binding var headingSelection: ContentItem.ID?
    @Binding var refreshIndexEvent: Int
    
    var body: some View {
        VStack {
                
            HStack {
                Text("Table of Contents")
                    .fontWeight(.thin)
                    .padding()
                
                Spacer()
                Button {
                    refreshIndexEvent += 1
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                        .padding()
                }
            }
//            .background(ThemeState.shared.theme.canvasColor.opacity(0.6))
            
            List(selection: $headingSelection) {
                ForEach($items, id: \.id) { $item in
                    HStack {
                        Spacer()
                            .frame(width: item.level.indexSpace)
                        Text(item.name)
                            .lineLimit(1)
                            .foregroundColor(item.level.indexColor)
                            .font(Font.system(size: item.level.indexFontSize, weight: item.level.indexWeight))
                    }
//                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
//            .background(ThemeState.shared.theme.canvasColor.opacity(0.6))
//            .scrollContentBackground(.hidden)
            
        }
//        .background(ThemeState.shared.theme.canvasColor.opacity(0.6))
    }
}
