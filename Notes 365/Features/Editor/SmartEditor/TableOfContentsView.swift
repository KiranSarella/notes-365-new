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
//            return 24
//        case .h2:
//            return 22
//        case .h3:
//            return 20
//        case .h4:
//            return 18
//        }
    }

    var indexSpace: CGFloat {
        switch self {
        case .h1:
            return 0
        case .h2:
            return 0
        case .h3:
            return 20
        case .h4:
            return 40
        }
    }
}


struct TableOfContentsView: View {
    @Binding var items: [[ContentItem]]
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
                ForEach($items, id: \.self) { $subItem in
                    
                    Section {
                        ForEach($subItem, id: \.id) { $item in
                            
                            if item.level == .h1 {
                                HStack {
                                    Spacer()
//                                        .frame(width: item.level.indexSpace)
                                    Text(item.name)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.primary.opacity(0.9))
                                        .fontWeight(item.level.indexWeight)
//                                        .font(.headline)
//                                        .font(Font.system(size: item.level.indexFontSize, weight: item.level.indexWeight))
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 20))
//                                        .padding()
                                    Spacer()
//                                        .frame(width: item.level.indexSpace)
                                }
//                                .listRowBackground(ThemeState.shared.theme.canvasColor.secondary)
                                .listRowBackground(Color.primary.colorInvert().opacity(0.6))
                                .listRowSeparator(.hidden)
//                                .foregroundColor(Color.secondary)
                            } else {
                                HStack {
                                    Spacer()
                                        .frame(width: item.level.indexSpace)
                                    Text(item.name)
                                        .lineLimit(1)
                                        .foregroundColor(item.level.indexColor)
                                        .fontWeight(item.level.indexWeight)
//                                        .font(Font.system(size: item.level.indexFontSize, weight: item.level.indexWeight))
                                }
                            }
                        }
                    }
                    
//                    .listRowBackground(Color.clear)
                }
            }
//            .listStyle(PlainListStyle())
            .background(ThemeState.shared.theme.canvasColor.opacity(0.6))
            .scrollContentBackground(.hidden)
            
        }
//        .background(ThemeState.shared.theme.canvasColor.opacity(0.6))
    }
}
