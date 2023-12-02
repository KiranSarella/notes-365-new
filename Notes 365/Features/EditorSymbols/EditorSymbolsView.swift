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
            .onChange(of: showSymbols, { old, new in
                for i in 0..<state.symbolsList.count {
                    state.symbolsList[i].editorView.editorType = new ? .markdown : .smart
                }
            })
        }
    }
}

struct EditorSymbolsView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSymbolsView()
    }
}

/// for text formatting options
struct ReadOnlyMarkDownViewThree: View {
    @Binding var timeline: ReadonlyEditorCache
    @Binding var showSymbols: Bool
    var body: some View {
        PreviewViewUI(text: timeline.content,
                     editorView: timeline.editorView,
                      editorType: showSymbols ? .markdown : .smart,
                      isConfigured: timeline.isConfigured
        )
        .frame(height: timeline.height)
        .onAppear {
            if timeline.isConfigured && timeline.isRefreshRequired == false {
                return
            }
            DispatchQueue.main.async {
                // set color
                timeline.editorView.textView.backgroundColor = UIColor.clear
                timeline.editorView.textView.sizeToFit()
                timeline.height = timeline.editorView.textView.intrinsicContentSize.height + 20
                // refresh purpose
                timeline.themeID = timeline.editorView.theme.id
                timeline.width = timeline.editorView.textView.intrinsicContentSize.width
                timeline.isConfigured = true
            }
        }
    }
}
