//
//  EditorSymbolsView.swift
//  Notes 365
//
//  Created by kiran ipc on 24/08/23.
//

import SwiftUI

struct EditorSymbolsView: View {
    
    @StateObject var state = EditorSymbolsState()
    @State var showSymbols: Bool = true
    
    var body: some View {
        GeometryReader { g in
            List(state.symbolsList) { symbol in
                Section(symbol.heading) {
                    VStack {
//                        Text(symbol.content)
                        ReadOnlySymbolsView(content: symbol.content, width: g.size.width, editorType: $state.editorType)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: -20, trailing: 0))
                    }
                }
            }
            .navigationBarTitle("Text Format Symbols")
        }
        .toolbar {
            Toggle("Show Symbols", isOn: $showSymbols)
        }
        .onChange(of: showSymbols) { newShowSymbols in
            state.editorType = (newShowSymbols == true) ? .markdown : .smart
        }

//        .listStyle(GroupedListStyle())
    }
}

struct EditorSymbolsView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSymbolsView()
    }
}
