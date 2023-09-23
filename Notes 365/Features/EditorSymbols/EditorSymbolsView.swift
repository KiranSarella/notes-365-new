//
//  EditorSymbolsView.swift
//  Notes 365
//
//  Created by kiran ipc on 24/08/23.
//

import SwiftUI

struct EditorSymbolsView: View {
    
    @State var state = EditorSymbolsState()
    @State var showSymbols: Bool = true
    
    var body: some View {
        
        NavigationStack {
            List($state.symbolsList) { $symbol in
                Section(symbol.heading) {
                    VStack {
                        ReadOnlyMarkDownViewThree(timeline: $symbol, showSymbols: $showSymbols)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 5, trailing: 0))
                    }
                }
            }
            .navigationBarTitle("Aa")
            .toolbar {
                Toggle("Show Symbols", isOn: $showSymbols)
                    .padding(.horizontal)
            }
            .onChange(of: showSymbols) { newShowSymbols in
    //            state.editorType = (newShowSymbols == true) ? .markdown : .smart
                for i in 0..<state.symbolsList.count {
                    state.symbolsList[i].editorView.editorType = newShowSymbols ? .markdown : .smart
                }
            }
        }
        
        

//        .listStyle(GroupedListStyle())
    }
}

struct EditorSymbolsView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSymbolsView()
    }
}
